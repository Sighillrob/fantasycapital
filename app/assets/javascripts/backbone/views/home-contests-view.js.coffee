class Main.Views.HomeContestsView extends Backbone.View
    initialize: (args) ->
        self = @
        @$el = $("#home-contests")
        @pusher = new Pusher(args.pusherkey)
        channel = this.pusher.subscribe('gamecenter')
        channel.bind('stats',  (data) -> self.pusherHandler(data) )
    pusherHandler: (data) ->
        console.log(data)