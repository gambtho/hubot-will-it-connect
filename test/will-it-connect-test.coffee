expect = require('chai').expect
nock = require('nock')
Helper = require('hubot-test-helper')
helper = new Helper('../src/will-it-connect.coffee')

sinon = require 'sinon'

process.env.HUBOT_WIC_PATH = "http://willitconnect.abc.io"

goodUrl = "amazon.com"
goodPort = "80"
badUrl = "test.com"
badPort = "800000"

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
    nock("http://willitconnect.abc.io")
    .post("/v2/willitconnect", {target: goodUrl + ":" + goodPort} )
    .reply 200, {
      "lastChecked": 0,
      "entry": goodUrl,
      "canConnect": true,
      "httpStatus": 200,
      "validHostname": true,
      "validUrl": true
    }
    nock("http://willitconnect.abc.io")
    .post("/v2/willitconnect", {target: goodUrl + ":" + badPort} )
    .reply 200, {
      "lastChecked": 0,
      "entry": goodUrl,
      "canConnect": false,
      "httpStatus": 200,
      "validHostname": true,
      "validUrl": true
    }
    nock("http://willitconnect.abc.io")
    .post("/v2/willitconnect", {target: badUrl + ":" + badPort} )
    .reply 404, {}



  afterEach ->
    room.destroy()
    nock.cleanAll()

  context 'user makes a bad request', ->
    beforeEach (done) ->
      room.robot.emit = sinon.spy()
      room.user.say 'alice', "hubot willitconnect blah"
      setTimeout done, 100

    it 'and it should reply with an error message for a request without a port',  ->
      expect(room.robot.emit.lastCall.args[1].content.pretext).equals("Please use this format: willitconnect <url:port>")
      expect(room.robot.emit.lastCall.args[1].content.title).equals("willItConnect: blah:null")
      expect(room.robot.emit.lastCall.args[1].content.color).equals("danger")

  context 'user makes a request that cannot connect to willitconnect', ->
    beforeEach (done) ->
      room.robot.emit = sinon.spy()
      room.user.say 'alice', "hubot willitconnect " + badUrl + ":" + badPort
      setTimeout done, 100

    it 'and it should reply with unable to connect information',  ->
      expect(room.robot.emit.firstCall.args[1].content.text).equals("Willitconnect error - I am unable to connect to willItConnect - null")
      expect(room.robot.emit.lastCall.args[1].content.title).equals("willItConnect: test.com:800000")
      expect(room.robot.emit.lastCall.args[1].content.color).equals("danger")

  context 'user request for a valid url and port combination', ->
    beforeEach (done) ->
      room.robot.emit = sinon.spy()
      room.user.say 'alice', "hubot willitconnect " + goodUrl + ":" + goodPort
      setTimeout done, 100

    it 'and it should reply with a positive response for reachable urls',  ->
      expect(room.robot.emit.firstCall.args[1].content.title).equals("willItConnect: amazon.com:80")
      expect(room.robot.emit.firstCall.args[1].content.title_link).equals("amazon.com:80")
      expect(room.robot.emit.firstCall.args[1].content.text).equals("I can connect")
      expect(room.robot.emit.firstCall.args[1].content.color).equals("good")

  context 'user request for a valid url but a bad port', ->
    beforeEach (done) ->
      room.robot.emit = sinon.spy()
      room.user.say 'alice', "hubot willitconnect " + goodUrl + ":" + badPort
      setTimeout done, 100

    it 'and it should reply with a negative response for unreachable urls',  ->
      expect(room.robot.emit.firstCall.args[1].content.text).equals("I cannot connect")
      expect(room.robot.emit.lastCall.args[1].content.title).equals("willItConnect: amazon.com:800000")
      expect(room.robot.emit.lastCall.args[1].content.color).equals("warning")


