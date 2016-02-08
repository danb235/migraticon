#!/usr/bin/env coffee

pkg = require '../package.json'
program = require 'commander'
Hipchat = require '../lib/hipchat'
async = require 'async'

program.version(pkg.version)

program.command('fetch')
  .description('Download all emoticons from hipchat account (requires group admin access)')
  .action () ->
    hipchat = new Hipchat

    # Perform action in series with async
    async.series [
      (callback) ->
        # get hipchat user credentials
        hipchat.promptUsername ->
          callback()
      # get list of emoticons
      (callback) ->
        hipchat.getHipchatEmoticons ->
          callback()
      (callback) ->
        # generate YAML file
        hipchat.generateYAML ->
          callback()
      (callback) ->
        # download emoticons
        hipchat.downloadAll ->
          callback()
    ], (err, results) ->
      throw err if err
      console.log 'Your emoticons have been downloaded to'.green.bold,
        """
        #{process.env.HOME or process.env.HOMEPATH or process.env.USERPROFILE}/Downloads/Hipchat_Emoticons
        """.green.bold
      process.exit()

program.parse(process.argv)

program.help() if program.args.length is 0
