(function () {
    "use strict";
    /*globals $, console */
    var lineup_players_view;


    function draftHandler () {

        var $draftEmitter  = $(".js-draft-emitter");
        var $draftReceiver = $(".js-draft-receiver");
        var $draftSearch   = $("#js-draft-search");
        var $sportFilter   = $("#filterSport");

        if ( !$draftEmitter.length || !$draftReceiver.length || !$sportFilter.length || !$draftSearch.length) {
            return null;
        }
        // bootstrap appends an arrow automatically

        function getArrow() {
            // other click event is set up on different element, we need to wait till it's done
            window.setTimeout(function () {
                var $activeTable = $draftReceiver.find(".active table");
                var tabClass = $activeTable.find("span.arrow").parent().attr("class");
                var clone = $activeTable.find("span.arrow").clone();
                $draftEmitter.find("span.arrow").remove();
                $draftEmitter.find("." + tabClass).append(clone);
            }, 10);
        }

        function setWidth() {
            window.setTimeout(function () {
                $draftReceiver.find(".tab-pane.active thead").removeClass("hide");
                $draftReceiver.find(".tab-pane.active th").each(function (index) {
                   var width = $(this).width();
                   $draftEmitter.find("th").eq(index).width(width);
                });
                $draftReceiver.find(".tab-pane.active thead").addClass("hide");
            }, 10);
        }
        
        getArrow();
        setWidth();

        $("#js-draft-search").unbind().on("keyup", function (e) {
            e.preventDefault();
            var term = $.trim(this.value).toUpperCase();
            $("#lineup-eligible-players-el tr").each(function () {
                var name = $.trim($(this).find(".player").text()).toUpperCase();
                if (name.match(term)) {
                    $(this).removeClass("hide");
                } else {
                    $(this).addClass("hide");
                }
            });
        });
        
        $draftEmitter.find("table").addClass("sortable");

        $draftEmitter.unbind().on("click", "thead th", function (e) {

            var $activeTable = $draftReceiver.find(".active table");
            var className = $(this).attr("class");
            $activeTable.find("th." + className).click();
            getArrow();

        });

        $("#filterSport").children("li").unbind().on("click", function (e) {
            e.preventDefault();
            // other click event handler is attached, it needs to be 
            // completed first before this code jumps in
            $(this).addClass("active").siblings("li").removeClass("active");

            var type = $.trim($(this).text());

            if (type === "ALL") {
                $("#lineup-eligible-players-el tr").removeClass("hide");
            } else {
                $("#lineup-eligible-players-el tr").each(function () {
                    var position = $.trim($(this).find(".position").text());
                    if (position !== type) {
                        $(this).addClass("hide");
                    } else {
                        $(this).removeClass("hide");
                    }
                });
            }

            setWidth();

        });
        
    }

    function populateDraftRows(players_coll) {
        // populate the rows in the draft table
        lineup_players_view = new Main.Views.LineupPlayerView(
            {el: $('#lineup-eligible-players-el'), players_coll: players_coll}
        )

    }

    $(document).on("ready page:load", function () {
        if ($("body#lineups_new").length) {
            //we are on new-lineup page.

            // call function defined in the Rails template. This populates the backbone collections
            ///  into the element specified here.
            var mybody = $("body")[0]
            init_colls(mybody);

            populateDraftRows(mybody.players_coll);

            // table's now populated. enable sort.

            // create player stats modal popup handler. Binds to appropriate rows.
            $(".player-stats").on('click', function () {
                new window.AjaxModal4Container($(this).data('stats-url')).load();
            });

            // create lineup object, (handles '+' for adding player to a lineup)
            new Lineup();

            // run bootstrap sortable. note 'reversed' used to make arrows show up the right way.
            $.bootstrapSortable(false);

            // this code is used to fix the scroll issue inside the lineups page
            // table layout doesn't allow separete thead and tbody
            draftHandler();


        }


    });

})();

