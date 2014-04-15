class Main.Views.HomeContestsView extends Backbone.View
    initialize: (args) ->
        self = @
        @$el = $("#home-contests")
        @pusher = new Pusher(args.pusherkey)
        channel = this.pusher.subscribe('gamecenter')
        channel.bind('stats',  (data) -> self.pusherHandler(data) )
    pusherHandler: (data) ->
        # { contests: [ { id: 642, contestants: Math.floor(Math.random() * 11), max_num_of_contestants: 10 } ] }
        # window.homeContestsView.pusherHandler({ contests: [ { id: 642, contestants: Math.floor(Math.random() * 11), max_num_of_contestants: 10 } ] });
        self = @
        if data.contests && _.isArray(data.contests)
            _(data.contests).each( (contest) ->
                node = self.$el.find("tr#contest_" + contest.id)
                if node.length > 0
                    node.find("td.entries-per-contest").html(contest.contestants + "/" + contest.max_num_of_contestants)
                    node.find("td")
                        .css({"background-color": "#0eea6c"}).stop(true)
                        .animate({ "background-color": "#eef0f1"}, 2000)
        )