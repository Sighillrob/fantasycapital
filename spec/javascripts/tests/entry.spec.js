"use strict";
/*globals $, describe, it, expect, Entry */

describe("Tests for an Entry", function () {
    
    function createEntry (position, spot, id) {
        var node = document.createElement("li");
        node.setAttribute("data-sport-position-name", position);
        node.setAttribute("data-spot", spot);
        node.setAttribute("data-player-id", id);
        return new Entry($(node));
    }

     function createPlayer (cfg) {
        var node = document.createElement("li");
        node.setAttribute("data-player-id", cfg.id);
        node.setAttribute("data-player-name", cfg.name);
        node.setAttribute("data-player-salary", cfg.salary);
        node.setAttribute("data-player-opp", cfg.opp);
        node.setAttribute("data-player-fppg", cfg.fppg);
        node.setAttribute("data-player-position", cfg.position);
        return new Player($(node));
    }

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

        var entry = createEntry("SPORT1", "SF", "null");
        expect(entry.position).toBe("SPORT1");
        expect(entry.spot).toBe("SF");
        expect(entry.player).toBe("");
        expect(entry.playerExists()).toBe(false);

    });

    it("You should be able to add a player to an entry", function () {

        var entry = createEntry("SPORT1", "SF", "null");
        expect(entry.playerExists()).toBe(false);

        var player = createPlayer({
            id: "XAB1",
            name: "Micheal Jordan",
            salary: 20000,
            opp: "XAB2",
            fppg: "XAB3",
            position: "SF"
        });

        entry.addPlayer(player);
        expect(entry.playerExists()).toBe(true);

    });

    it("You should be able to remove a player from an entry", function () {

        var entry = createEntry("SPORT1", "SF", "null");
        expect(entry.playerExists()).toBe(false);

        var player = createPlayer({
            id: "XAB1",
            name: "Micheal Jordan",
            salary: 20000,
            opp: "XAB2",
            fppg: "XAB3",
            position: "SF"
        });

        entry.addPlayer(player);
        expect(entry.playerExists()).toBe(true);


        entry.removePlayer();
        expect(entry.playerExists()).toBe(false);

    });

});