var GameCenterTests = _.extend({}, Backbone.Events);
GameCenterTests.on("players", function () {
  // change the ids of the players to fire it
  gamecenter.handlePushedStats({
    "players": [
      {
        "id": 410,
        "rtstats": "0P 1R 0A 1S 0B 0T",
        "currfps": Math.floor((Math.random() * 100))
      },
      {
        "id": 356,
        "rtstats": "3P 1R 1A 1S 0B 1T",
        "currfps": Math.floor((Math.random() * 100))
      },
      {
        "id": 314,
        "rtstats": "2P 3R 0A 0S 0B 0T",
        "currfps": Math.floor((Math.random() * 100))
      }
    ]
  })

});

GameCenterTests.on("entries", function () {

  console.log("X");

  function pushEntry(id) {
    gamecenter.handlePushedStats({
      "entries": [
        {
          "id": id,
          "fps": Math.floor((Math.random() * 100))
        }
      ]
    });
  }

  for (var i = 0, ilen = 100; i < ilen; i += 1) {
    pushEntry(i + 1);
  }

});
// fire off in console to see the flash
// GameCenterTests.trigger("players");
// GameCenterTests.trigger("entries");