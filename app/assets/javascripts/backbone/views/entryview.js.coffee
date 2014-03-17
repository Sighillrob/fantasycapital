class Main.Views.EntryView extends Backbone.View

  initialize: (args) ->
    console.log "hi from view"
    @template = $("#entry-template").html()
    @entry = args.entry
    @listenTo(@entry, 'change', @changeentry)
    @render()

  render: () ->
    console.log "hi from render"
    console.log this.$el
    # Look up the players for this entry
    players = @entry.players()
    $(@el).html(_.template(this.template, {entry: @entry, players: players}))
    $(@el).show()
    return this

  changeentry: () ->
    @render()
