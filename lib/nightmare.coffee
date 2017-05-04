Nightmare = require 'nightmare'
fs = require 'fs-extra'
async = require 'async'
colors = require 'colors'

browser = new Nightmare
  switches:
    'ignore-certificate-errors': true
  paths:
    userData: 'userData'

class Nightmare
  clearUserData: ->
    # remove the Electron userData from the system to be "incognito"
    fs.remove 'userData', (err) ->
      if err
        console.error(err)

  nightmareNavigate: (url, callback) ->
    console.log 'Navigating to', @hipchatURL + '...'
    # navigate nightmare to url
    browser
      .goto(url).run (err, results) ->
        callback()

  hipchatEnterCredentials: (callback) ->
    console.log 'Entering credentials for', @hipchatUsername, 'and logging in...'
    # enter hipchat credentials and make sure user can see emoticon table
    browser
      .wait('input[name="email"]')
      .type('input[name="email"]', @hipchatUsername)
      .click('input[name="signin"]')
      .wait('input[name="password"]')
      .type('input[name="password"]', @hipchatPassword)
      .wait('input[name="signin"]')
      .click('input[name="signin"]')
      .wait('.aui-page-panel-content')
      .wait('table[id="currentemoticons"]').run (err, results) =>
        if err
          # kill electron, inform user of error and kill the node process
          @electronEnd()
          console.log 'There is a problem accessing your hipchat emoticons.'.red.bold
          console.log 'Check your Hipchat credentials and that your account has admin access.'
          console.log 'If the problem persists, file an issue on github!'
          process.exit()
        else
          console.log 'Logged into', @hipchatUsername + '...'
        callback()

  hipchatLogin: (callback) ->
    # Perform action in series with async
    async.series [
      (callback) =>
        # navigate to emoticons
        @nightmareNavigate @hipchatURL, ->
          callback()
      (callback) =>
        # enter credentials
        @hipchatEnterCredentials ->
          callback()
    ], (err, results) ->
      callback err, results

  hipchatEmoticonHTML: (callback) ->
    console.log 'Looking for emoticons...'
    # get the html <body> when the table exists
    browser
      .wait('table[id="currentemoticons"]')
      .evaluate (->
        $("body").html()
      )
      .run((err, results) =>
        if err
          @electronEnd()
          console.log 'There is a problem accessing your hipchat emoticons.'.red.bold
          console.log 'It appears that there are no emoticons or your account does not have admin privileges.'
          console.log 'If the problem persists, file an issue on github!'
          process.exit()
        callback null, results
      )

  getHipchatEmoticons: (callback) ->
    # clear out electron userData since it is no longer needed
    @clearUserData()

    console.log '==> '.cyan.bold + 'logging into hipchat account and fetching list of emoticons'
    # Perform action in series with async
    async.waterfall [
      (callback) =>
        # login to hipchat
        @hipchatLogin (err, results) ->
          callback err, results
      (results, callback) =>
        # get the emoticon <body> html
        @hipchatEmoticonHTML (err, results) ->
          callback err, results
    ], (err, results) =>
      throw err if err
      # kill electron since we no longer need it
      @electronEnd()

      # look for emoticon urls and add them to array
      @urls = results.match(/https:\/\/.*.gif|https:\/\/.*.png/g)
      console.log 'Found', @urls.length, 'emoticons to download...'
      callback()

  electronEnd: ->
    # kill electron browser
    browser.end()

    # delete electron browser user data
    @clearUserData()

module.exports = Nightmare
