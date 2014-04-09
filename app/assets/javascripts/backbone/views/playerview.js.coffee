class Main.Views.PlayerView extends Backbone.View
    initialize: (args) ->
        @el = $("#player-dest")
        @position = args.position
        @percent  = args.percent
        @template = $("#player-template").html()
        _(@).bindAll("render")
        @model.bind("change", @render)
    render: () ->
        @sub = @el.find("tr[data-player-id=\"" + @model.get("id") + "\"]")
        content = _.template(@template, {
            model: @model, 
            position: @position,
            percent: @percent
        })
        if (!@sub.length)
            @el.append(content)
        else
            @sub.replaceWith(content)
class Main.Views.PlayersView extends Backbone.View
    initialize: (args) ->
        @el = $("#player-dest")
        @el.html("")
        @playerViews = {}
        @entry = args.entry
        @entryView = args.entryView
        @addAll()
    addAll: () ->
        self = @
        playersAndPositions = @entry.player_pos()
        playersAndPositions.forEach( (item) ->
            self.addOne(item)
        )
    addOne: (item) ->
        positions = ["ALL", "PG", "SG", "SF", "PF", "C", "UTIL"]
        playerView = new Main.Views.PlayerView({
            model: item[0]
            position: positions[item[1]]
            percent: @entryView.percent_owned()[item[0].get("id")]
        })
        @playerViews[item[0].get("id")] = playerView
        playerView.render()