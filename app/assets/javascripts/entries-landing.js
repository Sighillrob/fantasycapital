"use strict";
/* globals jQuery, _, fantasyEntries, moment */

(function ($) {


    var ns = {};

    ns.attach = function () {
        ns.dest = {
            live:      $(".live-contests-dest"),
            upcoming:  $(".upcoming-contests-dest"),
            completed: $(".completed-contests-dest")
        };

        ns.tpl = {
            live:      $("#live-contests-template").html(),
            upcoming:  $("#upcoming-contests-template").html(),
            completed: $("#completed-contests-template").html()
        };
    };

    ns.detach = function () {
        delete ns.dest;
        delete ns.tpl;
    };

    ns.url = "api/searchEntries";

    ns.cache = null;

    ns.checkConditions = function () {

        return typeof this.dest !== "undefined" &&
            typeof this.tpl !== "undefined" &&
            (this.dest.live.length > 0) &&
            (this.dest.upcoming.length > 0) &&
            (this.dest.completed.length > 0) &&
            this.tpl.live &&
            this.tpl.upcoming &&
            this.tpl.completed;
    };

    ns.ajax = function (callback, cached) {

        var self = this;

        if (typeof cached === "object") {
            ns.cache = cached;
            callback(self.parse(cached));
        } else {

            $.ajax({
                type: "GET",
                url: self.url,
                success: function (data) {
                    if (data && typeof data === "object") {
                        // save the original version in cache
                        ns.cache = data;
                        // fire off a callback with a cloned, parsed version
                        callback.call(self, self.parse(data));
                    }
                }
            });

        }
    };


    ns.parse = function (data) {
        // clone it
        data = $.extend(true, {}, data);

        _(data.liveContests).each(function (contest) {
            contest.render = {};
            contest.render.start_at = moment(contest.start_at).format("hh:mm a");
            //contest.render.end_at = moment(contest.end_at).subtract(moment()).format("hh:mm:ss");
        });
        _(data.upcomingContests).each(function (contest) {
            contest.render = {};
            contest.render.start_at = moment(contest.start_at).format("hh:mm a");
        });


        return data;
    };

    ns.manage = function (data) {

        this.render(data);
        this.countdown();

    };


    ns.render = function (data) {

        this.dest.live.html( _.template(this.tpl.live, data) );
        this.dest.upcoming.html( _.template(this.tpl.upcoming, data) );
        this.dest.completed.html( _.template(this.tpl.completed, data) );

    };

    ns.handle = function () {

        this.ajax(this.manage);

    };

    ns.padding = function (value) {

        if (value < 10 && value >= 0) {
            return "0" + value;
        }
        return value.toString();

    };

    ns.countdown = function () {


        var self = this;

        $(".js-time-count").countdown({
            date: $(this).attr("data-time"),
            render: function (date) {
                var min, sec, days;
                min = self.padding(date.min);
                sec = self.padding(date.sec);

                days = date.days;
                $(this).html(date.days * 24 + date.hours + ":" + min + ":" + sec);

            },
            onEnd: function () {
                self.handle();
            }
        });

    };


    ns.init = function () {
        ns.attach();
        // if there're no dest nodes
        if ( !this.checkConditions() ) {
            ns.detach();
            return null;
        }
        // do an ajax call, render and attach countdown
        this.handle();

    };

    window.fantasyEntries = ns;

})(jQuery);

jQuery(document).on("page:load ready", function () {
    fantasyEntries.init();
});