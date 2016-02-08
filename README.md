# migraticon
A simple CLI tool to download your ![hipchat](https://raw.githubusercontent.com/tkdan235/migraticon/4a713d5e94a62a3e4d6fd8b25ce2daecbdf51ea2/images/HipChat_sm.png) emoticons. Eventually with **migraticon** you will be able to upload them to ![slack](https://raw.githubusercontent.com/tkdan235/migraticon/4a713d5e94a62a3e4d6fd8b25ce2daecbdf51ea2/images/slack_sm.png) as well.

This project is early in dev and a WIP. Please file issues!

## Demo

![demo](https://cloud.githubusercontent.com/assets/3709575/12863656/389bb0d0-cc2e-11e5-8a23-6cbec2b14776.gif)

## About

Use **migraticon** to download your emoticons from hipchat:
* Logs into hipchat and get list of emoticons using [nightmarejs](http://www.nightmarejs.org/).
* Downloads emoticons to `~/Downloads/Hipchat_Emoticons`.
* Renames emoticons to get rid of there weird hipchat filenames.
* Grabs highest quality versions.

Coming soon:
* Use **migraticon** to upload your emoticons to slack

## Setup
### Dependencies

[NodeJS](http://nodejs.org/) is required to run **migraticon**. Find the installer and install the latest version; if using Mac OSX consider installing [homebrew](http://brew.sh/) and easily install what you need with the following:  

```
$ brew install node
```

### Install

Be sure all [dependencies](#Dependencies) are install before installing **migraticon**.

```
$ sudo npm install -g migraticon
```

### Uninstall

```
$ sudo npm uninstall -g migraticon
$ rm -rf ~/.migraticon
```

## Usage
See **migraticon** help for a full list of commands.

```
$ migraticon --help
```

### Basics

To download those emoticons enter the following:

```
$ migraticon fetch
```

## Contributing

If contributing clone the repo and run the following:

```
$ ./bin/migraticon --help
$ ./bin/migraticon fetch
```
