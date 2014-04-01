class Main.Views.UpcomingContestsView extends Backbone.View
    initialize: (contests) ->
        @template = $("#upcoming-contests-template").html()
        @upcomingContests = contests
        @listenTo(@upcomingContests, "change", @render)
        @render()
    render: () ->
        console.log(@upcomingContests.toJSON());
        console.log(_.template(@template, { upcomingContests: @upcomingContests.toJSON() }));