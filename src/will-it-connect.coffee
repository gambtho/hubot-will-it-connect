# Description
#   A hubot script that returns information about spring boot apps in slack
#
# Environment:
#   HUBOT_WIC_PATH must be set to a valid WIC endpoint
#
# Commands:
#   hubot willitconnect <host:port> - checks "willitconnect"
#
# Author:
#   gambtho <thomas_gamble@homedepot.com>
#

parser = require("parse-url")

WIC_PATH = process.env.HUBOT_WIC_PATH

module.exports = (robot) ->

  robot.respond /willitconnect (.*)$/i, (res) ->
    unless WIC_PATH?
      res.send "Please set HUBOT_WIC_PATH to a valid willitconnect instance in environment variables"
    parms = parser(res.match[1])
    port = parms.port
    host = parms.resource
    payload =
      title: "willItConnect: #{host}:#{port}"
      title_link: res.match[1]
    query host, port, (response, color, err) ->
      if err or not host or not port
        payload.pretext = "Please use this format: willitconnect <url:port>"
        payload.text = "Willitconnect error - #{err}"
        payload.color ="danger"
      else
        payload.text = response
        payload.color = color
      robot.emit 'slack-attachment',
        channel: res.envelope.room
        content: payload

  query = (host, port, cb) ->
    data = JSON.stringify({
      target: "#{host}:#{port}"
    })
    robot.http("#{WIC_PATH}/v2/willitconnect")
    .header('Content-Type', 'application/json')
    .post(data) (err, resp, body) ->
      if (err or resp.statusCode != 200)
        err = "I am unable to connect to willItConnect - #{err}"
        cb(null, "danger", err)
      else
        if(JSON.parse(body).canConnect)
          cb("I can connect", "good", null)
        else
          cb("I cannot connect", "warning", null)
