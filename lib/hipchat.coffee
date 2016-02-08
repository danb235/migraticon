Browser = require '../lib/nightmare'
async = require 'async'
fs = require 'fs-extra'
https = require 'https'
prompt = require 'prompt'
colors = require 'colors'
YAML = require 'js-yaml'
_ = require 'lodash'

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
    # get file name
    originalFile = url.replace(/^.*[\\\/]/, '')
    # get cleaned file name
    newFile = @getFileName url

    # download the emoticon
    console.log 'Downloading:'.yellow.bold, originalFile, '-->', @path + '/' + newFile
    file = fs.createWriteStream(@path + '/' + newFile)
    request = https.get(url, (response) ->
      response.pipe file
      callback()
    )

  getFileName: (url, callback) ->
    # get the emoticon filename
    file = url.replace(/^.*[\\\/]/, '')

    # clean out hipchat file hash from the filename
    if file.match(/-\w*@\w*/)
      file = file.replace(/-\w*@\w*/, '')
    else if file.match(/-\w*/)
      file = file.replace(/-\w*/, '')

  generateYAML: (callback) ->
    console.log '==> '.cyan.bold + 'generate emoji YAML file'
    # create emojis object
    emoticons = {}
    emoticons.title = @hipchatUsername
    emoticons.emojis = []
    _.each @urls, (url) =>
      emoticons.emojis.push
        name: @getFileName url
        src: url

    # convert object to yaml file
    yamlString = YAML.safeDump emoticons

    # write to disk
    ws = fs.createOutputStream(@path + '/' + @hipchatUsername + '.yaml')
    ws.write yamlString
    console.log @path + '/' + @hipchatUsername + '.yaml has been created...'
    callback()

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
