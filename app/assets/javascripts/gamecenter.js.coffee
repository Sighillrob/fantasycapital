

class window.GameCenterCls
    my_entry_id: 0

    pusher: null

#    stat_names: ['points', 'assists', 'steals', 'rebounds', 'blocks', 'turnovers']
#    stat_rules:
#        points: 1
#        assists: 1.5
#        steals: 2
#        rebounds: 1.25
#        blocks: 2
#        turnovers: -1

    handlePushedStats: (data) ->
        # handle stats received from Pusher(). We only receive stats that have changed. Update the
        # client-side player model with the data.
        context = @
        console.log (data)



        # update game states (do this first, b/c player states depend on it).
        $(data.games).each( (index, game) ->
                lcl_game = games_coll.get(game.id)
                if lcl_game
                  lcl_game.set(game)
        )
        # update player stats.
        $(data.players).each( (index, player) ->
              # skip players we don't have in this contest.
              lcl_player = players_coll.get(player.id)
              if lcl_player
                lcl_player.set(player)
        )
        # update entry values
        $(data.entries).each( (index, entry) ->
            lcl_entry = entries_coll.get(entry.id)
            if lcl_entry
              if entry.fps != lcl_entry.get("fps")
                lcl_entry.set(entry)
        )

        # re-sort entries collection so that highest fantasy points is first.
        # please note the every time the sort method is fired the view gets rendered once again
        # this happens even if the player is updated, we should avoid that
        entries_coll.sort()

        # this works

        $(data.entries).each( (index, entry) ->
          #find entry
          el = $("#entry-summarys-view-el").find("tr[data-entry-id=\"" + entry.id + "\"]")
          if el.length > 0
            #animate
            $("#entry-summarys-view-el").find("tr[data-entry-id=\"" + entry.id + "\"]").css({"background-color": "#0eea6c"}).animate({ "background-color": "#fff"}, 500)
        )

        # I've been unable to test this part of code b/c no games object was passed from the rake realtime:games_playback files
        $(data.games).each( (index, game) ->
            # check all tds
            $("#entry-summarys-view-el tr").each( () ->
                self = this
                #get all game ids which are used for the minutes_left() functionality
                ids = $(self).attr("data-games-id").split(",")
                # could be changed to normal loop
                ids.forEach( () ->
                    #if this id is the game.id which was updated then it means that we need to flash green in this row
                    if this == game.id
                        self.css({"background-color": "#0eea6c"}).animate({ "background-color": "#fff"}, 500)
                )
            )
        )


    constructor: (pusherkey) ->
        that = @

        console.log "GameCenter Constructor"

        @pusher = new Pusher(pusherkey)
        @my_entry_id = ($('.gamecenter').data('entry_id'))
        @my_contest_id = ($('.gamecenter').data('contest_id'))
        @gamesview = new Main.Views.GamesView({el: $('#gamesview_el'), games_coll: games_coll})

        @entrysummarys_view = new Main.Views.EntrySummarysView(
          {el: $('#entry-summarys-view-el'), entries_coll: entries_coll, players_coll: players_coll})

        channel = this.pusher.subscribe('gamecenter')
        @myentry = entries_coll.get(@my_entry_id)
        # trigger initial sort to make sure display is updated properly.
        entries_coll.sort()

        @myentryview = new Main.Views.EntryView({el: $('#my-scorecard'), entry: @myentry})

        channel.bind('stats',  (data) -> that.handlePushedStats(data) )
        this.attach_contestant_handler()
        this.attach_sort_handler()
        this.attach_pagination_handlers()


    # this piece of code should be moved to a parent view, however the "parent view" is rendered via server side atm
    # this can be rebuilded if needed, it's just a little maintenance issue
    attach_pagination_handlers: ->

        self = @
        $(".js-gc-paginate-previous").click (e) ->
            self.entrysummarys_view.prevPage()
        $(".js-gc-paginate-next").click (e) ->
            self.entrysummarys_view.nextPage()

    attach_contestant_handler: ->
        $(".gamecenter").on("click", "table.js-gamecenter tbody tr", (e) ->
            # user clicked on one of the contestants in top row. Get its entry id, populate that same entry ID
            # in the competitive scorecard, and then get the data for the scorecard from server.
            entryid = $(e.currentTarget).data("entry-id")
            $("#competitor-scorecard").attr("data-entry-id", entryid).hide()

            @competitorentry = entries_coll.get(entryid)
            @competitor_entry_view = new Main.Views.EntryView({el: $('#competitor-scorecard'), entry: @competitorentry})
        );
    attach_sort_handler: ->
        $table  = $(".js-gamecenter");
        $button = $(".js-gamecenter .js-sort-score");
        if !$table.length || !$button.length
            return null;
        $button.click (e) ->
            $rows = $table.find("tbody tr")
            direction = $(this).attr("data-direction")
            if $rows.length < 2
                return null
            else
                if direction == "desc"
                    opposite = "asc"
                    character = "&#x25B2;"
                else
                    opposite = "desc"
                    character = "&#x25BC;"

                $rows.tsort(".fantasypoints", {
                    order: opposite
                })
                $(this).removeClass("asc desc").addClass(opposite)
                $(this).find(".direction").html(character)
                $(this).attr("data-direction", opposite)
                return true
