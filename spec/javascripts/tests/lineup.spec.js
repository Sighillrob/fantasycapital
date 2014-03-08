"use strict";
/*globals $, describe, it, expect, Lineup */

describe("Tests for a Lineup", function () {

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

    it("Lineup should be a function", function () {
        expect(typeof Lineup).toBe("function");
    });

    it("Lineup should have salary cap set to 0 by default, and entries to be an empty array", function () {
        expect(Lineup.prototype.salary_cap).toBe(0);
        expect(Lineup.prototype.entries).toEqual([]);
    });

    it("You should be able to add entries to the lineup", function () {

        var entry1 = createEntry("POS1", "SF", "UNIQUE_ID_1");
        var entry2 = createEntry("POS2", "SM", "UNIQUE_ID_2");
        var entry3 = createEntry("POS3", "SG", "UNIQUE_ID_3");

        var lineup = new Lineup(65000);
        expect(lineup.getNumberOfEntries()).toBe(0);
        lineup.addEntry(entry1);
        lineup.addEntry(entry2);
        lineup.addEntry(entry3);
        expect(lineup.getSalaryCap()).toBe(65000);
        expect(lineup.getNumberOfEntries()).toBe(3);

    });

    it("You should be able to remove all entries from the lineup", function () {

        var entry1 = createEntry("POS1", "SF", "UNIQUE_ID_1");
        var entry2 = createEntry("POS2", "SM", "UNIQUE_ID_2");
        var entry3 = createEntry("POS3", "SG", "UNIQUE_ID_3");

        var lineup = new Lineup(65000);
        expect(lineup.getNumberOfEntries()).toBe(0);
        lineup.addEntry(entry1);
        lineup.addEntry(entry2);
        lineup.addEntry(entry3);
        expect(lineup.getSalaryCap()).toBe(65000);
        expect(lineup.getNumberOfEntries()).toBe(3);
        lineup.clearEntries();
        expect(lineup.getNumberOfEntries()).toBe(0);

    });

    it("You should be able to check sum of salaries", function () {

        var entry1 = createEntry("POS1", "SF", "UNIQUE_ID_1");
        var entry2 = createEntry("POS2", "SM", "UNIQUE_ID_2");
        var entry3 = createEntry("POS3", "SG", "UNIQUE_ID_3");

        var player1 = createPlayer({
            id: "XAB1",
            name: "Micheal A",
            salary: 6000,
            opp: "XAB2",
            fppg: "XAB3",
            position: "SF"
        });

        var player2 = createPlayer({
            id: "YBB1",
            name: "Micheal B",
            salary: 2000,
            opp: "YBB2",
            fppg: "YBB3",
            position: "SM"
        });

        var player3 = createPlayer({
            id: "ZCB1",
            name: "Micheal C",
            salary: 15000,
            opp: "ZCB2",
            fppg: "ZCB3",
            position: "SG"
        });

        entry1.addPlayer(player1);
        entry2.addPlayer(player2);
        entry3.addPlayer(player3);

        var lineup = new Lineup(65000);
        lineup.addEntry(entry1);
        lineup.addEntry(entry2);
        lineup.addEntry(entry3);
        expect(lineup.consumedSalary()).toBe(23000);

    });

    it("You should be able to check if you can add player safely so you don't exceed the limit", function () {

        var entry1 = createEntry("POS1", "SF", "UNIQUE_ID_1");
        var entry2 = createEntry("POS2", "SM", "UNIQUE_ID_2");
        var entry3 = createEntry("POS3", "SG", "UNIQUE_ID_3");
        var entry4 = createEntry("POS4", "SX", "UNIQUE_ID_4");
        var entry5 = createEntry("POS5", "SQ", "UNIQUE_ID_5");

        var player1 = createPlayer({
            id: "XAB1",
            name: "Micheal A",
            salary: 5000,
            opp: "XAB2",
            fppg: "XAB3",
            position: "SF"
        });

        var player2 = createPlayer({
            id: "YBB1",
            name: "Micheal B",
            salary: 6000,
            opp: "YBB2",
            fppg: "YBB3",
            position: "SM"
        });

        var player3 = createPlayer({
            id: "ZCB1",
            name: "Micheal C",
            salary: 7000,
            opp: "ZCB2",
            fppg: "ZCB3",
            position: "SG"
        });

        var player4 = createPlayer({
            id: "HCB1",
            name: "Micheal Q",
            salary: 7000,
            opp: "HCB2",
            fppg: "HCB3",
            position: "SA"
        });

        var player5 = createPlayer({
            id: "VCB1",
            name: "Silver Goldman",
            salary: 999999,
            opp: "VCB2",
            fppg: "VCB3",
            position: "SQ"
        });

        entry1.addPlayer(player1);
        entry2.addPlayer(player2);
        entry3.addPlayer(player3);
        entry4.addPlayer(player4);
        entry5.addPlayer(player5);

        var lineup = new Lineup(65000);
        lineup.addEntry(entry1);
        lineup.addEntry(entry2);
        lineup.addEntry(entry3);
        expect(lineup.canAddPlayer(player4)).toBe(true);
        lineup.addEntry(entry4);
        expect(lineup.canAddPlayer(player5)).toBe(false);

    });

    it("You should be able to remove all players from the lineup", function () {
        var entry1 = createEntry("POS1", "SF", "UNIQUE_ID_1");
        var entry2 = createEntry("POS2", "SM", "UNIQUE_ID_2");
        var entry3 = createEntry("POS3", "SG", "UNIQUE_ID_3");

        var player1 = createPlayer({
            id: "XAB1",
            name: "Micheal A",
            salary: 6000,
            opp: "XAB2",
            fppg: "XAB3",
            position: "SF"
        });

        var player2 = createPlayer({
            id: "YBB1",
            name: "Micheal B",
            salary: 2000,
            opp: "YBB2",
            fppg: "YBB3",
            position: "SM"
        });

        var player3 = createPlayer({
            id: "ZCB1",
            name: "Micheal C",
            salary: 15000,
            opp: "ZCB2",
            fppg: "ZCB3",
            position: "SG"
        });

        entry1.addPlayer(player1);
        entry2.addPlayer(player2);
        entry3.addPlayer(player3);

        var lineup = new Lineup(65000);
        lineup.addEntry(entry1);
        lineup.addEntry(entry2);
        lineup.addEntry(entry3);
        expect(lineup.consumedSalary()).toBe(23000);
        lineup.clear();
        expect(lineup.consumedSalary()).toBe(0);
        expect(lineup.getNumberOfEntries()).toBe(3);
    });

    it("You should be able to count how much money you've still got", function () {
        var entry1 = createEntry("POS1", "SF", "UNIQUE_ID_1");

        var player1 = createPlayer({
            id: "XAB1",
            name: "Micheal A",
            salary: 6000,
            opp: "XAB2",
            fppg: "XAB3",
            position: "SF"
        });

        entry1.addPlayer(player1);


        var lineup = new Lineup(65000);
        lineup.addEntry(entry1);
        expect(lineup.getSalaryCap()).toBe(65000);
        expect(lineup.consumedSalary()).toBe(6000);
        expect(lineup.amountLeft()).toBe(59000);


    });

    it("You should be able to find out how many spots are still empty", function () {
        var entry1 = createEntry("POS1", "SF", "UNIQUE_ID_1");
        var entry2 = createEntry("POS2", "SM", "UNIQUE_ID_2");
        var entry3 = createEntry("POS3", "SG", "UNIQUE_ID_3");

        var lineup = new Lineup(100000);
        lineup.addEntry(entry1);
        lineup.addEntry(entry2);
        lineup.addEntry(entry3);
        expect(lineup.spotsLeft()).toBe(3);

        var player1 = createPlayer({
            id: "XAB1",
            name: "Micheal A",
            salary: 6000,
            opp: "XAB2",
            fppg: "XAB3",
            position: "SF"
        });

        entry1.addPlayer(player1);
        expect(lineup.spotsLeft()).toBe(2);

        var player2 = createPlayer({
            id: "YBB1",
            name: "Micheal B",
            salary: 2000,
            opp: "YBB2",
            fppg: "YBB3",
            position: "SM"
        });

        entry2.addPlayer(player2);
        expect(lineup.spotsLeft()).toBe(1);

        var player3 = createPlayer({
            id: "ZCB1",
            name: "Micheal C",
            salary: 15000,
            opp: "ZCB2",
            fppg: "ZCB3",
            position: "SG"
        });

        entry3.addPlayer(player3);
        expect(lineup.spotsLeft()).toBe(0);

        lineup.clear();
        expect(lineup.spotsLeft()).toBe(3);

    });

    it("You should be able to count all players in the lineup", function () {
        var entry1 = createEntry("POS1", "SF", "UNIQUE_ID_1");
        var entry2 = createEntry("POS2", "SM", "UNIQUE_ID_2");
        var entry3 = createEntry("POS3", "SG", "UNIQUE_ID_3");

        var lineup = new Lineup(100000);
        lineup.addEntry(entry1);
        lineup.addEntry(entry2);
        lineup.addEntry(entry3);
        expect(lineup.spotsLeft()).toBe(3);

        var player1 = createPlayer({
            id: "XAB1",
            name: "Micheal A",
            salary: 6000,
            opp: "XAB2",
            fppg: "XAB3",
            position: "SF"
        });

        entry1.addPlayer(player1);
        expect(lineup.spotsTaken()).toBe(1);

        var player2 = createPlayer({
            id: "YBB1",
            name: "Micheal B",
            salary: 2000,
            opp: "YBB2",
            fppg: "YBB3",
            position: "SM"
        });

        entry2.addPlayer(player2);
        expect(lineup.spotsTaken()).toBe(2);

        var player3 = createPlayer({
            id: "ZCB1",
            name: "Micheal C",
            salary: 15000,
            opp: "ZCB2",
            fppg: "ZCB3",
            position: "SG"
        });

        entry3.addPlayer(player3);
        expect(lineup.spotsTaken()).toBe(3);

        lineup.clear();
        expect(lineup.spotsTaken()).toBe(0);
    });

    it("You should be able to find out what's the average remaining salary in the lineup", function () {
      
        var entry1 = createEntry("POS1", "SF", "UNIQUE_ID_1");
        var entry2 = createEntry("POS2", "SM", "UNIQUE_ID_2");
        var entry3 = createEntry("POS3", "SG", "UNIQUE_ID_3");

        var player1 = createPlayer({
            id: "XAB1",
            name: "Micheal A",
            salary: 6000,
            opp: "XAB2",
            fppg: "XAB3",
            position: "SF"
        });

        var player2 = createPlayer({
            id: "YBB1",
            name: "Micheal B",
            salary: 2000,
            opp: "YBB2",
            fppg: "YBB3",
            position: "SM"
        });

        var player3 = createPlayer({
            id: "ZCB1",
            name: "Micheal C",
            salary: 13000,
            opp: "ZCB2",
            fppg: "ZCB3",
            position: "SG"
        });

        entry1.addPlayer(player1);
        entry2.addPlayer(player2);
        entry3.addPlayer(player3);

        var lineup = new Lineup(65000);
        lineup.addEntry(entry1);
        lineup.addEntry(entry2);
        lineup.addEntry(entry3);
        // ( 13000 + 2000 + 6000 ) / 3 
        expect(lineup.averagePlayerSalary()).toBe(7000);
        expect(lineup.averageRemainingPlayerSalary()).toBe(Infinity);

    });

});