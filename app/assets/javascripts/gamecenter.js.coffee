class window.GameCenterCls
    my_entry_id: 0

    # client-side models:
    players: {}
    entries: {}
    contest: {}
    my: {}

    pusher: null

    stat_names: ['points', 'assists', 'steals', 'rebounds', 'blocks', 'turnovers']
    stat_rules:
        points: 1
        assists: 1.5
        steals: 2
        rebounds: 1.25
        blocks: 2
        turnovers: -1

    handlePushedStats: (data) ->
        # handle stats received from Pusher(). We only receive stats that have changed. Update the
        # client-side player model with the data.
        context = this
        console.log (data)
        # update player stats.
        $(data.players).each( (index, player) ->
            # skip players we don't have in this contest.
            if (context.players[player.id])
                context.players[player.id].stats[player.stat_name] = player.stat_value
                context.update_dom_for_player(context.players[player.id])
        )

        # update entry values (fp scores).
        $(data.entries).each( (index, entry) ->
            context.entries[entry.id] = entry
            context.update_dom_for_entry(context.entries[entry.id])
        )

        # update contest states
        $(data.contests).each ((index, contest) ->
            # ignore non-matching contests (this is a broadcast channel to multiple recipients)
            if contest.id == context.my_contest_id
                context.contest = contest
                context.update_dom_for_contest(contest)
        )

    constructor: ->
        that = @

        console.log "GameCenter Constructor"
        this.pusher = new Pusher('<%= Rails.env.development? ? "86296472974842e38cce" : Pusher.key %>')
        this.my_entry_id = ($('.gamecenter').data('entry_id'))
        this.my_contest_id = ($('.gamecenter').data('contest_id'))

        this.getData()

        channel = this.pusher.subscribe('gamecenter')

        channel.bind('stats',  (data) -> that.handlePushedStats(data) )
        this.attach_contestant_handler()
        this.attach_sort_handler()

    attach_contestant_handler: ->
        $("table.freeroll tbody tr").click (e) ->
            # user clicked on one of the contestants in top row. Get its entry id, populate that same entry ID
            # in the competitive scorecard, and then get the data for the scorecard from server.
            entryid = $(e.currentTarget).data("entry-id")
            console.log(e)
            console.log(entryid)
            $("#competitor-scorecard").attr("data-entry-id", entryid).hide()

            $.ajax(
                method: "GET"
                url: "/api/gc_data/" + entryid
                context: that
            ).success( (data, status, headers, config) ->
                this.handleEntryData(data, status, headers, config)
            ).error (data, status, headers, config) ->
                console.log('error')
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
    update_dom_for_contest: (contest) ->
        # take the current self.contest value and update fields in the DOM.
        make_live_btn = $('#admin_buttons_form input[value="Make Live"]')
        if (contest.live)
            livetext = "LIVE IN PLAY"
            make_live_btn.hide()
        else
            livetext = "not live"
            make_live_btn.show()
        $('#is_contest_live_text').html(livetext)

    update_dom_for_entry: (entry) ->
        # accept an entry instance, and update it in the DOM. It might exist both in a scorecard,
        # as well as in the contestants in the top.
        matched_scorecards = $(".scorecard[data-entry-id=" + entry.id + "]")
        matched_contestants = $(".freeroll tr[data-entry-id=" + entry.id + "]")

        matched_scorecards.each( (index, scorecard) ->
            $(scorecard).find('.total-score').html(entry.fps)

        )
        matched_contestants.each( (index, contestant) ->
            $(contestant).find('td.fantasypoints').html(entry.fps)
        )


    update_dom_for_player: (player) ->

        # accept a player instance, and update it in the DOM. Find matching DOM rows (there could
        # be more than 1) and change their HTML.
        context = this
        $(".scorecard tr[data-player-id=" + player.id + "]").each( (index, scorecardrow) ->
            $(scorecardrow).find('.player-name').html(player.first_name + " " + player.last_name)
            $(scorecardrow).find('.salary').html(player.salary)
            $(scorecardrow).find('.score').html(player.stats['fp'])
            records = []
            # fill out the detailed stats ("0 P 1 A ...")
            $(context.stat_names).each((i, stat_name) ->
                txt = player.stats[stat_name] + " " + stat_name.charAt(0)
                records.push(txt)
            )
            $(scorecardrow).find('.records').html(records.join(', '))
        )

    refreshMyLineup: (data) ->
        # update a scorecard's DOM using data received from server.
        scorecard_to_update = $(".scorecard[data-entry-id=" + data.entry.id + "]")
        scorecard_tbody = scorecard_to_update.find("tbody")
        $(scorecard_to_update).find(".username").html(data.my.username)
        $(scorecard_to_update).find(".total-score").html(data.curr_fp)

        # remove the table rows before refreshing.
        $(scorecard_tbody.find("tr")).each(->
            $(this).remove()
        )
        this.data = data
        context = this
        $(context.data.lineup_spots).each((index, lineup_spot) ->
            # Build each row in the scorecard and attach it to DOM.

            scorecardrow = $('tr.lineup-row-template').clone() \
                .removeClass('lineup-row-template').attr("data-player-id", lineup_spot.player.id) \
                .appendTo(scorecard_tbody)
            $(scorecardrow).find('.role').html(lineup_spot.sport_position.name)
            context.update_dom_for_player(context.players[lineup_spot.player.id], scorecardrow)

        )
        $(scorecard_to_update).show()

    getData: ->
        # ajax call to get an entry's static information.
        that = @
        $.ajax(
            method: "GET"
            url: "/api/gc_data/" + that.my_entry_id
            context: this
        ).success(
                this.handleEntryData

        ).error (data, status, headers, config) ->
            console.log('error')

    handleEntryData: (data, status, headers, config) ->
        # callback from ajax to get an entry. save the player data as a client-side model so it
        # can be partially updated via websocket.
        context = this
        $(data.lineup_spots).each((index, lineup_spot) ->
            context.players[lineup_spot.player.id] = lineup_spot.player

            # slight friction between AJAX and Pusher API -- stats is in lineup in AJAX, while
            # it's in "player" in the Pusher.
            context.players[lineup_spot.player.id].stats = lineup_spot.stats
        )
        this.refreshMyLineup(data)


$(document).on('page:load ready', ->
    if $('.gamecenter').length > 0
        window.gamecenter = new GameCenterCls
)
