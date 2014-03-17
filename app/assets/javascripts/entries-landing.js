<<<<<<< HEAD
"use strict";
/* globals jQuery, _, FANTASY, moment */

(function ($) {
=======
/* globals jQuery, _, FANTASY */
(function ($) {
    "use strict";
>>>>>>> e9aac2227b03e6782c8925abc905e60510910221

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
<<<<<<< HEAD
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
=======
    }

    ns.url = "api/searchEntries";

    ns.cache = {};

    ns.checkConditions = function () {

        return this.dest.live.length &&
            this.dest.upcoming.length &&
            this.dest.completed.length &&
>>>>>>> e9aac2227b03e6782c8925abc905e60510910221
            this.tpl.live &&
            this.tpl.upcoming &&
            this.tpl.completed;
    };

<<<<<<< HEAD
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

=======
    ns.ajax = function (callback) {

        var self = this;

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
>>>>>>> e9aac2227b03e6782c8925abc905e60510910221
    };

    ns.parse = function (data) {
        // clone it
        data = $.extend(true, {}, data);

        _(data.liveContests).each(function (contest) {
            contest.render = {};
            contest.render.start_at = moment(contest.start_at).format("hh:mm a");
            contest.render.end_at = moment(contest.end_at).subtract(moment()).format("hh:mm:ss");
        });
        _(data.upcomingContests).each(function (contest) {
            contest.render = {};
            contest.render.start_at = moment(contest.start_at).format("hh:mm a");
        });


        return data;
<<<<<<< HEAD
    };

    ns.manage = function (data) {

        this.render(data);
        this.countdown();

    };
=======
    }
>>>>>>> e9aac2227b03e6782c8925abc905e60510910221

    ns.render = function (data) {

        this.dest.live.html( _.template(this.tpl.live, data) );
        this.dest.upcoming.html( _.template(this.tpl.upcoming, data) );
        this.dest.completed.html( _.template(this.tpl.completed, data) );

    };

<<<<<<< HEAD
    ns.handle = function () {

        this.ajax(this.manage);

    };

    ns.padding = function (value) {

        if (value < 10 && value >= 0) {
            return "0" + value;
        }
        return value.toString();

    }

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

=======
>>>>>>> e9aac2227b03e6782c8925abc905e60510910221
    ns.init = function () {
        ns.attach();
        // if there're no dest nodes
        if ( !this.checkConditions() ) {
<<<<<<< HEAD
            ns.detach();
            return null;
        }
        // do an ajax call, render and attach countdown
        this.handle();

    };

    window.fantasyEntries = ns;

})(jQuery);

jQuery(document).ready(function () {
    fantasyEntries.init();
});
=======
            return null;
        }

        this.ajax(this.render);


    };

    window.FANTASY = ns;

})(jQuery);

jQuery(document).ready(function ($) {
    
    FANTASY.init(); 
});
>>>>>>> e9aac2227b03e6782c8925abc905e60510910221
