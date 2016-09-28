# Description:
#   Tabletennis leaderboard and tournament handler
#
#
# Commands:
#   hubot pong? - show help for pongbot
#   hubot pong I won against <@user> - records the match in the leaderboard
#   hubot pong player leaderboard - shows the monthly player leaderboard
#   hubot pong top player - shows the top player of the monthly leaderboard
#
# Author:
#   @smiklos

winnerResponses = [((player) -> "#{player} had no luck this time"), ((player) -> "Don't give up #{player}"), ((player) -> "#{player} maybe you shouldn't play more today...")]

module.exports = (robot) ->

  robot.respond /pong player leaderboard *$/i, (msg) ->
    showLeaderBoard(msg, 10)

  robot.respond /pong top player *$/i, (msg) ->
    showLeaderBoard(msg, 1)

  robot.respond /pong I won against @?(\w+) *$/i, (msg) ->
    winner = msg.message.user.name.toLowerCase()
    looser = msg.match[1].toLowerCase().replace("@","").trim()
    match = createMatch(winner, looser)
    recordMatch(getOrCreatePlayerData(winner),getOrCreatePlayerData(looser),match)
    msg.send msg.random(winnerResponses)(looser)

  robot.respond /pong\?? *$/i, (msg) ->
    msg.send """
            hubot pong I won against <@user> - records the match in the leaderboard
            hubot pong player leaderboard - shows the monthly player leaderboard
            hubot pong top player - shows the top player of the monthly leaderboard
            """

  getOrCreatePlayerData = (userName) ->
     robot.brain.data["pongplayer_#{userName}"] = robot.brain.data["pongplayer_#{userName}"] or
     {
             userName : userName,
             wins : 0,
             losses : 0,
     }

  recordMatch = (winner, looser, match) ->
    winner.wins = winner.wins + 1
    looser.losses = looser.losses + 1
    addMatch(match)
    updateLeaderBoard(match)

  createMatch = (winnerName, looserName) ->
    {
             winner : winnerName,
             looser : looserName,
             timestamp : new Date()
    }

  addMatch = (match) ->
    playerMatches = getPlayerMatches(match.timestamp)
    robot.brain.data[playerMatches] = robot.brain.data[playerMatches] or []
    robot.brain.data[playerMatches].push(match)

  updateLeaderBoard = (match) ->
    leaderboardKey = getLeaderBoardKey(match.timestamp)
    robot.brain.data[leaderboardKey] = robot.brain.data[leaderboardKey] or {}
    winner  = getScore(robot.brain.data[leaderboardKey],match.winner)
    winner.wins = winner.wins + 1
    looser  = getScore(robot.brain.data[leaderboardKey],match.looser)
    looser.losses = looser.losses + 1

  getLeaderBoardKey = (timestamp) ->
    "pong_player_leaderboard_#{getYearAndMonth(timestamp)}"

  getPlayerMatches = (timestamp) ->
    "pong_player_matches_#{getYearAndMonth(timestamp)}"

  getScore = (leaderboard, playerKey) ->
    leaderboard[playerKey] = leaderboard[playerKey] or {
          wins : 0,
          losses: 0
    }

  showLeaderBoard = (msg, requested) ->
    leaderboardKey = getLeaderBoardKey(new Date())
    robot.brain.data[leaderboardKey] = robot.brain.data[leaderboardKey] or {}
    leaderboard = robot.brain.data[leaderboardKey]
    orderedPlayers = do (leaderboard) ->
      keys = Object.keys(leaderboard).sort (a, b) ->
        winsToCompare = leaderboard[b].wins - leaderboard[a].wins
        if winsToCompare == 0
          leaderboard[a].losses - leaderboard[b].losses
        else
          winsToCompare
    leaderboardMessage = ""
    for player, position in orderedPlayers.slice(0,requested)
      leaderboardMessage += "#{position + 1}. #{player} with #{leaderboard[player].wins} wins and #{leaderboard[player].losses} losses \n"
    msg.send leaderboardMessage or "No matches played yet"

  getYearAndMonth = (timestamp) ->
    "#{timestamp.getFullYear()}-#{timestamp.getMonth() + 1}"
