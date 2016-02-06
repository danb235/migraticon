Browser = require '../lib/nightmare'
async = require 'async'
fs = require 'fs-extra'
https = require 'https'
prompt = require 'prompt'
colors = require 'colors'

class Hipchat extends Browser
  hipchatURL: 'https://www.hipchat.com/sign_in?d=/emoticons'
  hipchatUsername: undefined
  hipchatPassword: undefined
  urls: undefined
  path: """
  #{process.env.HOME or process.env.HOMEPATH or process.env.USERPROFILE}/Downloads/Hipchat_Emoticons
  """

  downloadAll: (callback) ->
    console.log '==> '.cyan.bold + 'download emoticons'

    # make sure the download path exists and directory is created
    fs.ensureDirSync @path

    # iterate through array of urls and download emoticons
    download = (iteration) =>
      @downloadEmoticon @urls[iteration], =>
        if @urls.length is iteration + 1
          callback null, @path
        else
          download(iteration + 1)
    download(0)

  downloadEmoticon: (url, callback) ->
    # get the emoticon filenames
    urlfilename = url.replace(/^.*[\\\/]/, '')
    if urlfilename.match(/-\w*@\w*/)
      urlfilenameClean = urlfilename.replace(/-\w*@\w*/, '')
    else if urlfilename.match(/-\w*/)
      urlfilenameClean = urlfilename.replace(/-\w*/, '')

    # download the emoticon
    console.log 'Downloading:'.yellow.bold, urlfilename, '-->', @path + '/' + urlfilenameClean
    file = fs.createWriteStream(@path + '/' + urlfilenameClean)
    request = https.get(url, (response) ->
      response.pipe file
      callback()
    )

  promptUsername: (callback) ->
    # prompt the user for their hipchat credentials
    prompt.message = "migraticon".yellow
    prompt.delimiter = ": ".green
    prompt.properties =
      username:
        description: 'Hipchat Username (must be admin)'
        pattern: /^(([^<>()[\]\.,;:\s@\"]+(\.[^<>()[\]\.,;:\s@\"]+)*)|(\".+\"))@(([^<>()[\]\.,;:\s@\"]+\.)+[^<>()[\]\.,;:\s@\"]{2,})$/i
        required: true
      password:
        description: 'Hipchat Password'
        pattern: /^.*$/
        required: true
        password:
          hidden: true

    prompt.start()
    prompt.get ['username', 'password'], (error, result) =>
      @hipchatUsername = result.username
      @hipchatPassword = result.password
      callback()

module.exports = Hipchat
