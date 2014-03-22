(function () {
    "use strict";



    function draftHandler () {

        var $draftEmitter  = $(".js-draft-emitter");
        var $draftReceiver = $(".js-draft-receiver");
        var $sportFilter   = $("#filterSport");

        if ( !$draftEmitter.length || !$draftReceiver.length || !$sportFilter.length) {
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
        
        $draftEmitter.find("table").addClass("sortable");

        $draftEmitter.unbind().on("click", "thead th", function (e) {

            var $activeTable = $draftReceiver.find(".active table");
            var className = $(this).attr("class");
            $activeTable.find("th." + className).click();
            getArrow();

        });

        $sportFilter.children("li").on("click", function () {
            // other click event handler is attached, it needs to be 
            // completed first before this code jumps in
            getArrow();
            setWidth();

        });

    }

    $(document).on("ready page:load", function () {

        // this code is used to fix the scroll issue inside the lineups page
        // table layout doesn't allow separete thead and tbody
        draftHandler();
       

    });

})();

