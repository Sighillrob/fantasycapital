class Main.Views.EntryView extends Backbone.View

  initialize: (args) ->
    @template = $("#entry-template").html()
    @entry = args.entry
    @listenTo(@entry, 'change', @changeentry)
    @listenTo(window.players_coll, 'change', @changeentry)
    @render()


  get_players_count: () ->
    stats = {}
    entries_coll.each( (entry, index) ->
      player_ids = entry.get_player_ids()
      _.each player_ids, (num) ->
        if !stats[num]
          stats[num] = 1
        else
          stats[num] += 1
    )
    return stats
  percent_owned: () ->
    players_count = @get_players_count()
    contestants_count = entries_coll.length
    for key, value of players_count
      players_count[key] = Math.round( (value / contestants_count) * 100)
    return players_count
  render: () ->
    # Look up the players for this entry
    console.log("render entry")

    player_and_pos = @entry.player_pos()
    $.each(player_and_pos,  (idx, pl_pos) ->
      if pl_pos[0].get('rtstats')
        console.log pl_pos[0].get('rtstats')
    )

    $(@el).html(_.template(this.template, {
      entry: @entry, 
      player_and_pos: player_and_pos, 
      user_img: window.user_img_placeholder,
      percentage: @percent_owned()
    }))
    $(@el).show()
    return this

  changeentry: () ->
    @render()
