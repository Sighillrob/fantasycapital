class Main.Views.EntryView extends Backbone.View

  initialize: (args) ->
    @template = $("#entry-template").html()
    @entry = args.entry
    @listenTo(@entry, 'change', @changeentry)
    @render()

  render: () ->
    # Look up the players for this entry
    players = @entry.players()
    $(@el).html(_.template(this.template, {entry: @entry, players: players, user_img: window.user_img_placeholder}))
    $(@el).show()
    return this

  changeentry: () ->
    @render()
