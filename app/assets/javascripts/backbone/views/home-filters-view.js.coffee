class Main.Views.HomeFiltersView extends Backbone.View
    initialize: () ->
        @$el = $("#home-game-filters")
        if @$el.length > 0
            @attachToggleHandler()
            @attachCheckboxHandler()
    attachToggleHandler: () ->
        self = @
        @$el.find("#home-filter-games").on("click", () ->
            self.toggleFilters()
        )
    attachCheckboxHandler: () ->
        @$el.find(".checkbox-toggle").on("click", () ->
            $(@).toggleClass("active")
            val = $(@).attr("data-value")
            $(@).attr("data-value", val == "false" ? "true" : "false")
        )
    toggleFilters: () ->
        @$el.find("#home-filter-games").toggleClass("active");
        @$el.find("#home-filter-options").toggleClass("hide");