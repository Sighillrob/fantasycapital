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

    player_and_pos = @entry.player_pos()
    $.each(player_and_pos,  (idx, pl_pos) ->
      if pl_pos[0].get('rtstats')
        console.log pl_pos[0].get('rtstats')

    )


    $(@el).html(_.template(this.template, {entry: @entry, player_and_pos: player_and_pos, user_img: window.user_img_placeholder}))
    $(@el).show()
    return this

  changeentry: () ->
    @render()
