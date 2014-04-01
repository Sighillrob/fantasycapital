class Main.Views.LiveContestsView extends Backbone.View
    initialize: (contests) ->
        @$el = $(".live-contests-dest")
        @template = $("#live-contests-template").html()
        @liveContests = contests
        @listenTo(@liveContests, "change", @render)
        @render()
    render: () ->
        @$el.html(_.template(@template, { liveContests: @liveContests.toJSON() }))