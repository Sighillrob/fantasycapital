class Main.Views.EntryView extends Backbone.View

  initialize: (args) ->
    @template = $("#entry-template").html()
    @entry = args.entry
    @listenTo(@entry, 'change', @changeentry)
    @listenTo(window.players_coll, 'change', @changeentry)
    @render()

  render: () ->
    # Look up the players for this entry
    console.log("render entry")

    players = @entry.players()
    $.each(players,  (idx, player) ->
      if player.get('rtstats')
        console.log player.get('rtstats')
    )


    $(@el).html(_.template(this.template, {entry: @entry, players: players, user_img: window.user_img_placeholder}))
    $(@el).show()
    return this

  changeentry: () ->
    @render()
