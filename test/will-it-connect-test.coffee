expect = require('chai').expect
nock = require('nock')
Helper = require('hubot-test-helper')
helper = new Helper('../src/will-it-connect.coffee')

sinon = require 'sinon'

process.env.HUBOT_WIC_PATH = "http://willitconnect.abc.io"

describe 'will-it-connect', ->
  room = null
  beforeEach ->
    room = helper.createRoom()

    nock("http://willitconnect.abc.io")
    .get("/willitconnect?host=amazon.com&port=80")
    .reply 200, "I can connect to amazon.com on 80"
    nock("http://willitconnect.abc.io")
    .get("/willitconnect?host=amazon.com&port=8090")
    .reply 200, "I cannot connect to amazon.com on 8090"
    nock("http://willitconnect.abc.io")
    .get("/willitconnect?host=amazon.com&port%3D800000")
    .reply 400, "not seen"

  afterEach ->
    room.destroy()
    nock.cleanAll()

#  context 'user makes a bad request', ->
#    beforeEach (done) ->
#      room.robot.emit = sinon.spy()
#      room.user.say 'alice', "hubot willitconnect blah"
#      setTimeout done, 100
#
#    it 'and it should reply with an error message for a request without a port',  ->
#      expect(room.robot.emit.lastCall.args[1].content.title).equals("willItConnect: blah:null")
#
#  context 'user makes a request that cannot connect', ->
#    beforeEach (done) ->
#      room.robot.emit = sinon.spy()
#      room.user.say 'alice', "hubot willitconnect amazon.com:800000"
#      setTimeout done, 100
#
#    it 'and it should reply with unable to connect information',  ->
#      expect(room.robot.emit.lastCall.args[1].content.title).equals("willItConnect: amazon.com:800000")
#      expect(room.robot.emit.lastCall.args[1].content.color).equals("danger")
#
#  context 'user request for a valid url', ->
#    beforeEach (done) ->
#      room.robot.emit = sinon.spy()
#      room.user.say 'alice', "hubot willitconnect amazon.com:8090"
#      room.user.say 'alice', "hubot willitconnect amazon.com:80"
#      setTimeout done, 100
#
#    it 'and it should reply with a negative response for unreachable urls',  ->
#      expect(room.robot.emit.firstCall.args[1].content.title).equals("willItConnect: amazon.com:8090")
#      expect(room.robot.emit.firstCall.args[1].content.title_link).equals("amazon.com:8090")
#      expect(room.robot.emit.firstCall.args[1].content.text).equals("I cannot connect to amazon.com on 8090")
#      expect(room.robot.emit.firstCall.args[1].content.color).equals("warning")
#    it 'and it should reply with a positive response for reachable urls',  ->
#      expect(room.robot.emit.lastCall.args[1].content.title).equals("willItConnect: amazon.com:80")
#      expect(room.robot.emit.lastCall.args[1].content.title_link).equals("amazon.com:80")
#      expect(room.robot.emit.lastCall.args[1].content.text).equals("I can connect to amazon.com on 80")
#      expect(room.robot.emit.lastCall.args[1].content.color).equals("good")

  context 'user request for a valid url', ->
    beforeEach (done) ->
      room.robot.emit = sinon.spy()
      room.user.say 'alice', "hubot willitconnect http://amazon.com:80"
      setTimeout done, 100

    it 'and it should reply with a positive response for reachable urls',  ->
      expect(room.robot.emit.lastCall.args[1].content.title).equals("willItConnect: amazon.com:80")
      expect(room.robot.emit.lastCall.args[1].content.title_link).equals("http://amazon.com:80")
      expect(room.robot.emit.lastCall.args[1].content.text).equals("I can connect to amazon.com on 80")
      expect(room.robot.emit.lastCall.args[1].content.color).equals("good")

