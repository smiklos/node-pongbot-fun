Helper = require('hubot-test-helper')
helper = new Helper('pongbot.coffee')

co     = require('co')
expect = require('chai').expect

describe 'pong test', ->

  beforeEach ->
    @room = helper.createRoom()

  afterEach ->
    @room.destroy()

  context 'pong help', ->
    beforeEach ->
      co =>
        yield @room.user.say 'miklos', '@hubot pong?'

    it 'should tell user "Who wants to play some pingpong?"', ->
      expect(@room.messages).to.eql [
        ['miklos', '@hubot pong?']
        ['hubot', 'hubot pong I won against <@user> - records the match in the leaderboard\nhubot pong player leaderboard - shows the monthly player leaderboard\nhubot pong top player - shows the top player of the monthly leaderboard']
      ]

  context 'pong I won against user', ->
    beforeEach ->
      co =>
        yield @room.user.say 'miklos', '@hubot pong I won against Nikolaj'
        yield @room.user.say 'nikolaj', '@hubot pong I won against Miklos'
        yield @room.user.say 'miklos', '@hubot pong I won against @nikolaj'

    it 'should tell user "miklos I added you!"', ->
      expect(@room.robot.brain.data["pongplayer_miklos"]).to.eql  {

                userName : "miklos",
                wins : 2,
                losses : 1
        }
      expect(@room.robot.brain.data["pongplayer_nikolaj"]).to.eql  {

                userName : "nikolaj",
                wins : 1,
                losses : 2
        }


  context 'show leaderboard', ->
    beforeEach ->
      co =>
        yield @room.robot.brain.data["pong_player_leaderboard_2016-9"] = {
            miklos :
                {
                   wins : 5,
                   losses : 2
                }
            nikolaj :
                {
                   wins : 3,
                   losses : 2
                }
            hans :
                {
                   wins : 3,
                   losses : 1
                }
            rozsi :
                {
                   wins : 5,
                   losses : 4
                }
          }
        yield @room.user.say 'miklos', '@hubot pong player leaderboard'


    it 'should show the full leaderboard', ->
      expect(@room.messages).to.eql [
        ['miklos', '@hubot pong player leaderboard']
        ['hubot', "1. miklos with 5 wins and 2 losses \n2. rozsi with 5 wins and 4 losses \n3. hans with 3 wins and 1 losses \n4. nikolaj with 3 wins and 2 losses \n"]
      ]
