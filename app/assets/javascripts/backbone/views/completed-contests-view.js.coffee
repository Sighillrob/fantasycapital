class Main.Views.CompletedContestsView extends Backbone.View
    initialize: (contests) ->
        @$el = $(".completed-contests-dest")
        @template = $("#completed-contests-template").html()
        @completedContests = contests
        @listenTo(@completedContests, "change", @render)
        @render()
    render: () ->
        if @el && @template
            @$el.html(_.template(@template, { completedContests: @completedContests.toJSON() }))