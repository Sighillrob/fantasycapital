describe("Tests for an Entry", function () {
    
    it("Entry should be a function", function () {
        expect(typeof Entry).toBe("function");
    });

    it("Entry shouldn't have position, player and spot by default", function () {
        expect(Entry.prototype.position).toBe("");
        expect(Entry.prototype.player).toBe("");
        expect(Entry.prototype.spot).toBe("");
    });

    it("Entry should have a render method in it's prototype", function () {
        expect(typeof Entry.prototype.render).toBe("function");
    });

    it("Entry should receive a dom node which has sport-position-name, spot and played-id data attributes set", function () {

        var node = document.createElement("li");
        node.setAttribute("data-sport-position-name", "SPORT1");
        node.setAttribute("data-spot", "SF");
        node.setAttribute("data-player-id", "null");

        var entry = new Entry($(node));
        expect(entry.position).toBe("SPORT1");
        expect(entry.spot).toBe("SF");
        expect(entry.player).toBe("");

    });

});