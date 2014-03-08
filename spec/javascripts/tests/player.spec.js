"use strict";
/*globals $, describe, it, expect, Player */

describe("Tests for a Player", function () {
    
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

    it("Player should be a function", function () {
        expect(typeof Player).toBe("function");
    });

    it("Player should have salary set to 0 by default, and id, name, opp, fppg, position have to be empty", function () {
        expect(Player.prototype.id).toBe("");
        expect(Player.prototype.name).toBe("");
        expect(Player.prototype.salary).toBe(0);
        expect(Player.prototype.opp).toBe("");
        expect(Player.prototype.fppg).toBe("");
        expect(Player.prototype.position).toBe("");
    });


    it("Player should have id, name, salary, opp, fppg and position set", function () {

        var player = createPlayer({
            id: "XAB1",
            name: "Micheal Jordan",
            salary: 20000,
            opp: "XAB2",
            fppg: "XAB3",
            position: "SF"
        });

        expect(player.id).toBe("XAB1");
        expect(player.name).toBe("Micheal Jordan");
        expect(player.salary).toBe(20000);
        expect(player.opp).toBe("XAB2");
        expect(player.fppg).toBe("XAB3");
        expect(player.position).toBe("SF");

    });

});