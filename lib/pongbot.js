// Generated by CoffeeScript 1.11.0
(function() {
  var winnerResponses;

  winnerResponses = [
    (function(player) {
      return player + " had no luck this time";
    }), (function(player) {
      return "Don't give up " + player;
    }), (function(player) {
      return player + " maybe you shouldn't play more today...";
    })
  ];

  module.exports = function(robot) {
    var addMatch, createMatch, getLeaderBoardKey, getOrCreatePlayerData, getPlayerMatches, getScore, getYearAndMonth, recordMatch, showLeaderBoard, updateLeaderBoard;
    robot.respond(/pong player leaderboard *$/i, function(msg) {
      return showLeaderBoard(msg, 10);
    });
    robot.respond(/pong top player *$/i, function(msg) {
      return showLeaderBoard(msg, 1);
    });
    robot.respond(/pong I won against @?(\w+) *$/i, function(msg) {
      var looser, match, winner;
      winner = msg.message.user.name.toLowerCase();
      looser = msg.match[1].toLowerCase().replace("@", "").trim();
      match = createMatch(winner, looser);
      recordMatch(getOrCreatePlayerData(winner), getOrCreatePlayerData(looser), match);
      return msg.send(msg.random(winnerResponses)(looser));
    });
    robot.respond(/pong\?? *$/i, function(msg) {
      return msg.send("hubot pong I won against <@user> - records the match in the leaderboard\nhubot pong player leaderboard - shows the monthly player leaderboard\nhubot pong top player - shows the top player of the monthly leaderboard");
    });
    getOrCreatePlayerData = function(userName) {
      return robot.brain.data["pongplayer_" + userName] = robot.brain.data["pongplayer_" + userName] || {
        userName: userName,
        wins: 0,
        losses: 0
      };
    };
    recordMatch = function(winner, looser, match) {
      winner.wins = winner.wins + 1;
      looser.losses = looser.losses + 1;
      addMatch(match);
      return updateLeaderBoard(match);
    };
    createMatch = function(winnerName, looserName) {
      return {
        winner: winnerName,
        looser: looserName,
        timestamp: new Date()
      };
    };
    addMatch = function(match) {
      var playerMatches;
      playerMatches = getPlayerMatches(match.timestamp);
      robot.brain.data[playerMatches] = robot.brain.data[playerMatches] || [];
      return robot.brain.data[playerMatches].push(match);
    };
    updateLeaderBoard = function(match) {
      var leaderboardKey, looser, winner;
      leaderboardKey = getLeaderBoardKey(match.timestamp);
      robot.brain.data[leaderboardKey] = robot.brain.data[leaderboardKey] || {};
      winner = getScore(robot.brain.data[leaderboardKey], match.winner);
      winner.wins = winner.wins + 1;
      looser = getScore(robot.brain.data[leaderboardKey], match.looser);
      return looser.losses = looser.losses + 1;
    };
    getLeaderBoardKey = function(timestamp) {
      return "pong_player_leaderboard_" + (getYearAndMonth(timestamp));
    };
    getPlayerMatches = function(timestamp) {
      return "pong_player_matches_" + (getYearAndMonth(timestamp));
    };
    getScore = function(leaderboard, playerKey) {
      return leaderboard[playerKey] = leaderboard[playerKey] || {
        wins: 0,
        losses: 0
      };
    };
    showLeaderBoard = function(msg, requested) {
      var i, leaderboard, leaderboardKey, leaderboardMessage, len, orderedPlayers, player, position, ref;
      leaderboardKey = getLeaderBoardKey(new Date());
      robot.brain.data[leaderboardKey] = robot.brain.data[leaderboardKey] || {};
      leaderboard = robot.brain.data[leaderboardKey];
      orderedPlayers = (function(leaderboard) {
        var keys;
        return keys = Object.keys(leaderboard).sort(function(a, b) {
          var winsToCompare;
          winsToCompare = leaderboard[b].wins - leaderboard[a].wins;
          if (winsToCompare === 0) {
            return leaderboard[a].losses - leaderboard[b].losses;
          } else {
            return winsToCompare;
          }
        });
      })(leaderboard);
      leaderboardMessage = "";
      ref = orderedPlayers.slice(0, requested);
      for (position = i = 0, len = ref.length; i < len; position = ++i) {
        player = ref[position];
        leaderboardMessage += (position + 1) + ". " + player + " with " + leaderboard[player].wins + " wins and " + leaderboard[player].losses + " losses \n";
      }
      return msg.send(leaderboardMessage || "No matches played yet");
    };
    return getYearAndMonth = function(timestamp) {
      return (timestamp.getFullYear()) + "-" + (timestamp.getMonth() + 1);
    };
  };

}).call(this);
