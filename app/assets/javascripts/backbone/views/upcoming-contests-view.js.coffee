class Main.Views.UpcomingContestsView extends Backbone.View
    initialize: (contests) ->
        @$el = $(".upcoming-contests-dest")
        @template = $("#upcoming-contests-template").html()
        @upcomingContests = contests
        @listenTo(@upcomingContests, "change", @render)
        @render()
    render: () ->
        @$el.html(_.template(@template, { upcomingContests: @upcomingContests.toJSON() }))