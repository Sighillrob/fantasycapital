# == Schema Information
#
# Table name: players
#
#  id                :integer          not null, primary key
#  created_at        :datetime
#  updated_at        :datetime
#  sport_position_id :integer
#  salary            :integer
#  first_name        :string(255)
#  last_name         :string(255)
#  dob               :date
#  ext_player_id     :string(255)
#  team_id           :integer
#

class Player < ActiveRecord::Base
  PRIORITIZE_SEQUENCE_NUMBER = 1
  FP_TO_SALARY_MULTIPLIER    = 250
  PLAYER_MIN_SALARY = 3000
  NBA_STATS_ORDER = ['points', 'rebounds', 'assists', 'steals', 'blocks', 'turnovers']

  belongs_to :team
  belongs_to :sport_position
  has_many :player_stats, inverse_of: :player
  has_many :player_real_time_scores
  validates :sport_position_id, presence: true    # don't allow nil sport-position
  has_many :lineup_spots

  def name
    "#{first_name} #{last_name}"
  end

  def realtime_fantasy_points(gameid=nil)
    # return current real-time-fantasy score for a particular game ID, or array of gameid's.
    # to use an eager-loaded association that's been pre-filtered to only include the relevant game(s),
    # make sure gameid is nil.

    # if this player has an eager-loaded set of realtime scores, use those to save queries.
    # those should already be pre-scoped to the game-ids we care about.
    if gameid.nil? && (self.association_cache.keys.include? :player_real_time_scores)
      fpsarray = self.player_real_time_scores.to_a.select { |x| x['name'] == 'fp' }
      if fpsarray.length > 1
        ext_game_ids = fpsarray.map {|x| GameScore.find(x['game_score_id']).ext_game_id}
        raise "More than one cached fantasy score for #{self.name}. Games=#{ext_game_ids}"
      end

      fps = fpsarray[0]
    else
      fpsarray = player_real_time_scores.where(game_score_id: gameid, name: 'fp')
      raise "More than one fantasy score for #{self.name}" if fpsarray.count > 1
      fps = fpsarray.first
    end

    fps.try(:value) || 0
  end

  def fantasy_points
    Projection::Projection.where(player_id: Projection::Player.where(ext_player_id: ext_player_id).first).order(updated_at: :desc).first.try(:fp) || 0
  end



  def rtstats(gameid=nil)

    # return the score-string (ie "0 P 0 R 0 S ...") for this player in a particular game.
    # can pass an array of gameids. Make sure we assemble in right order.
    # to use an eager-loaded association that's been pre-filtered to only include the relevant game(s),
    # make sure gameid is nil.

    # if this player has an eager-loaded set of realtime scores, use those to save queries.
    # those should already be pre-scoped to the game-ids we care about.
    if gameid.nil? && (self.association_cache.keys.include? :player_real_time_scores)
      stats = self.player_real_time_scores.to_a
    else
      stats = player_real_time_scores.where(game_score_id: gameid)
    end

    rtstats = []
    stats.to_a.each do |rtstat|
      idx = NBA_STATS_ORDER.index(rtstat['name'])
      unless idx.nil?
        rtstats[idx] = rtstat['value'].to_i.to_s + rtstat['name'][0]
      end

    end
    # use 'compact' to remove nil entries (in case we only have partial data)
    rtstats.compact.join(" ").upcase
  end

  class << self
    def refresh_all(players_src, team_src)
      players_src.each do |player_src|
        player = Player.where(ext_player_id: player_src['id']).first_or_initialize
        player.last_name = player_src['last_name']
        player.first_name = player_src['first_name']

        # for some reason the team 'name' is different here than in the other API. Add 'market' to it
        player.team = Team.where(ext_team_id: team_src['id']).first_or_create do |team|
          team.name = "#{team_src['market']} #{team_src['name']}"
          team.teamalias = team_src['alias']
        end

        player.dob = Time.parse(player_src['birthdate'])

        #salary is fp * 250 rounded to nearest 100
        salary = (player.fantasy_points * FP_TO_SALARY_MULTIPLIER / 100.0).round * 100
        #min 3000
        player.salary = [salary, PLAYER_MIN_SALARY].max

        player.sport_position = SportPosition.where(name: player_src['primary_position'], sport: 'NBA').first
        player.save!
      end
    end

    def with_summary_fppg
      # return players with their summary FPPG stats as a 'joins'. Caller can then 'select' out
      # the fields they want to display, including the joined FPPG summary stat.

      # my most complex query ever:
      # we need the associated PlayerStat FPPG score marked 'summary' for each player, the one with
      # the highest display-priority.
      # 1. Use a LEFT JOIN so we get players with no stats. (we've seen a few of those)
      # 2. Put conditions in the JOIN (instead of in a where), again so we keep players
      #    without stats.
      # 3. Use a nested query to select only the Player+PlayerStat entry with highest display-priority
      joinclause = "LEFT JOIN player_stats ON player_stats.player_id = players.id " +
          "AND player_stats.stat_name = 'FPPG' AND player_stats.dimension = 'summary'"

      innerquery = "(SELECT MAX (player_stats.display_priority) from player_stats " +
          "WHERE player_stats.player_id = players.id)"

      joins(joinclause).where('player_stats IS null OR player_stats.display_priority= ' + innerquery)

    end

    def player_of_ext_id(ext_id)
      player = find_by_ext_player_id ext_id
      if player.nil?
        logger.warn "#{ext_id} not found.... Skipped"
      else
        yield player
      end
      player
    end

  end
end
