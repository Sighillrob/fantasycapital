var GameCenterTests = _.extend({}, Backbone.Events);
GameCenterTests.on("push-players", function () {
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
// fire off in console to see the flash
// GameCenterTests.trigger("push-players");