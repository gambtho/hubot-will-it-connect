# Description
#   A hubot script that returns information about spring boot apps in slack
#
# Environment:
#   HUBOT_WIC_PATH must be set to a valid WIC endpoint
#
# Commands:
#   hubot willitconnect <url:port> - checks "willitconnect"
#
# Author:
#   gambtho <thomas_gamble@homedepot.com>
#


#WIC_PATH = process.env.HUBOT_WIC_PATH
WIC_PATH="http://willitconnect.cfapps.io"

module.exports = (robot) ->

  robot.respond /willitconnect (.*)$/i, (res) ->
    unless WIC_PATH?
      res.send "Please set HUBOT_WIC_PATH to a valid willitconnect instance in environment variables"
    validateURL res, (host, port, err) ->
      return emitData(res, err) if err
      payload =
        title: "willItConnect: #{host}:#{port}"
        title_link: res.match[1]
      query host, port, (response, color, err) ->
        return emitData res,"Willitconnect error - #{err}" if err
        console.log "payload is: #{payload}"
        payload.text = response
        payload.color = color
        robot.emit 'slack-attachment',
          channel: res.envelope.room
          content: payload

  validateURL = (res, cb) ->
    urlPattern = /https?:\/\/|([^\s]+\.[^\s]{2,}):(\d{2,6})/
    if (res.match[1].match(urlPattern))
      inputs = urlPattern.exec(res.match[1])
      console.log "string is #{res.match[1]}"
      console.log "inputs = #{inputs}"
      host = inputs[1]
      port = inputs[2]
      console.log "host is: #{host}, port is: #{port}"
      cb(host, port, null)
    else
      cb(null, null, "Invalid Url - please use this format: willitconnect <url:port>")

  emitData = (res, string="Willitconnect Error") ->
    payload =
      title: string
      color: "danger"
    robot.emit 'slack-attachment',
      channel: res.envelope.room
      content: payload

  query = (host, port, cb) ->
    console.log "in query - host: #{host}, port: #{port}"
    robot.http("#{WIC_PATH}/willitconnect?host=#{host}&port=#{port}")
    .get() (err, resp, body) ->
      console.log "error is #{err}"
      if (err or not resp.statusCode == 200)
        err = "I am unable to connect to willItConnect - #{err}"
        cb(null, null, err)
      else
        console.log "body is: #{body}, resp is: #{body}"
        if(body.match(/I can connect to (.*)/))
          cb(body, "good", err)
        else
          cb(body, "warning", err)






