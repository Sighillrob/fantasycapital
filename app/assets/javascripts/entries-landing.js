/* globals jQuery, _, FANTASY */
(function ($) {
    "use strict";

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
    }

    ns.url = "api/searchEntries";

    ns.cache = {};

    ns.checkConditions = function () {

        return this.dest.live.length &&
            this.dest.upcoming.length &&
            this.dest.completed.length &&
            this.tpl.live &&
            this.tpl.upcoming &&
            this.tpl.completed;
    };

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
    }

    ns.render = function (data) {

        this.dest.live.html( _.template(this.tpl.live, data) );
        this.dest.upcoming.html( _.template(this.tpl.upcoming, data) );
        this.dest.completed.html( _.template(this.tpl.completed, data) );

    };

    ns.init = function () {
        ns.attach();
        // if there're no dest nodes
        if ( !this.checkConditions() ) {
            return null;
        }

        this.ajax(this.render);


    };

    window.FANTASY = ns;

})(jQuery);

jQuery(document).ready(function ($) {
    
    FANTASY.init(); 
});
