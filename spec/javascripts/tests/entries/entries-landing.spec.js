"use strict";
/*globals fantasyEntries */

describe("Tests for the entries landing script", function () {

    it("should have an attach method which will grab all templates and destination nodes", function () {

        expect(typeof fantasyEntries.dest).toBe("undefined");
        expect(typeof fantasyEntries.tpl).toBe("undefined");
        fantasyEntries.attach();
        expect(typeof fantasyEntries.dest).toBe("object");
        expect(typeof fantasyEntries.tpl).toBe("object");
        fantasyEntries.detach();
        expect(typeof fantasyEntries.dest).toBe("undefined");
        expect(typeof fantasyEntries.tpl).toBe("undefined");

    });

    it("the cache should be empty before loading the data", function () {
        expect(fantasyEntries.cache).toBe(null);
    });

    it ("the cache should be filled after the data is loaded via ajax or from fixtures", function () {
        fantasyEntries.ajax(function () {}, FIXTURES.contests);
        expect(fantasyEntries.cache).toBe(FIXTURES.contests);
        fantasyEntries.cache = null;
    });

    it("check if conditions are met", function () {
        // it should be false, the templates aren't available yet
        expect(fantasyEntries.checkConditions()).toBe(false);
    });

    it("should have an url provided for the ajax call, it won't work without it", function () {

        expect(typeof fantasyEntries.url).toBe("string");
        expect(fantasyEntries.url.length).toBeGreaterThan(0);

    });

    it("the data set should contain 3 arrays, liveContests, upcomingContests and completedContests", function () {
        var data = FIXTURES.contests;
        expect($.isArray(data.liveContests)).toBe(true);
        expect($.isArray(data.upcomingContests)).toBe(true);
        expect($.isArray(data.completedContests)).toBe(true);
    });

    it("the parse function should adjust the start_at and end_at fields", function () {

        var data = fantasyEntries.parse(FIXTURES.contests);
        console.log(data);
        // render property is being added to the liveContests
        expect(typeof data.liveContests[0].render).toBe("object");
        // render property is being added to the upcomingContests
        expect(typeof data.upcomingContests[0].render).toBe("object");

    });

    it("padding should be added correctly", function () {
        expect(fantasyEntries.padding(8)).toBe("08");
        expect(fantasyEntries.padding(10)).toBe("10");
        expect(fantasyEntries.padding(0)).toBe("00");
    });

});