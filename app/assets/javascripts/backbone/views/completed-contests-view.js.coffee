class Main.Views.CompletedContestsView extends Backbone.View
    initialize: (contests) ->
        @template = $("#completed-contests-template").html()
        @completedContests = contests
        @listenTo(@completedContests, "change", @render)
        @render()
    render: () ->
        console.log(@completedContests.toJSON());
        console.log(_.template(@template, { completedContests: @completedContests.toJSON() }));