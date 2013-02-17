# Description:
#   Returns title and description when links are posted
#
# Dependencies:
#   "jsdom": "0.2.15"
#
# Configuration:
#
# Optional Configuration:
#   HUBOT_HTTP_INFO_IGNORE_URLS - RegEx used to exclude Urls
#   HUBOT_HTTP_INFO_IGNORE_USERS - Comma separated list of users to ignore
#
# Commands:
#   http(s)://<site> - prints the title and meta description for sites linked.
#
# Author:
#   ajacksified

jsdom = require 'jsdom'
_     = require 'underscore'

module.exports = (robot) ->

  ignoredusers = []
  if process.env.HUBOT_HTTP_INFO_IGNORE_USERS?
    ignoredusers = process.env.HUBOT_HTTP_INFO_IGNORE_USERS.split(',')

  robot.hear /http(s?):\/\/(.*)/i, (msg) ->
    url = msg.match[0]

    username = msg.message.user.name
    if _.some(ignoredusers, (user) -> user == username)
      console.log 'ignoring user due to blacklist:', username
      return

    # filter out some common files from trying
    ignore = url.match(/\.(png|jpg|jpeg|gif|txt|zip|tar\.bz|js|css)/)

    ignorePattern = process.env.HUBOT_HTTP_INFO_IGNORE_URLS
    if !ignore && ignorePattern
      ignore = url.match(ignorePattern)

    unless ignore
      jsdom.env(
        html: msg.match[0]
        scripts: [
          'http://code.jquery.com/jquery-1.7.2.min.js'
        ]
        done: (errors, window) ->
          unless errors
            $ = window.$
            title = $('title').text()
            description = $('meta[name=description]').attr("content") || ""
            description = "\n" + description if description

            if title
              msg.send "#{title}#{description}"
        )
