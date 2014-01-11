class RenameOpponentTeamToAwayTeamInProjectionGame < ActiveRecord::Migration
  def change
    rename_column projection_games :opponent_team, :away_team
  end
end
