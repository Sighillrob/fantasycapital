class Main.Views.LiveContestsView extends Backbone.View
    initialize: (contests) ->
        @template = $("#live-contests-template").html()
        @liveContests = contests
        @listenTo(@liveContests, "change", @render)
        @render()
    render: () ->
        console.log(@liveContests.toJSON());
        console.log(_.template(@template, { liveContests: @liveContests.toJSON() }));