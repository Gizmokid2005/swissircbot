SwissIRCBot - A Ruby IRC bot 
============================

SwissIRCBot is an IRC bot written in Ruby based off of [Cinch](https://github.com/cinchrb/cinch) that aims to be the everything bot.

### SwissIRCBot is still very early in development. The readme and documentation will be expanded in due time.

Configuration
-------------
The configuration is stored by default in a `irc.yml` file that lives in the same directory as `swissircbot.rb`. The following configuration options are available:

`server` -- The address of the IRC Server.

`nick` -- The username (nick) of the bot.

`password` -- The password for the account the `nick` is associated with.

The list of channels and their associated admins. Must maintain this indentation structure: 
```yaml
admin:
  channel:
    '#channel1':
    - 'User'
```
The list of channels to join:
```yaml
channels:
- '#channel1'
- '#channel2'
```

`notadmin` -- The message to return when someone is not an admin.

`notopbot` -- The message to return when the bot is not an op to handle certain tasks.

`logfile` -- The location of the logfile for your bot.

`commandprefix` -- The character to designate a command in IRC.

`wweatherapikey` -- The API key for WorldWeather for `weather` commands.

`wuweatherapikey` -- The API key for WeatherUnderground for `wu` commands.

`googleapikey` -- The API key for Google for URL shortening (not required).

`darkskyapikey` -- The API key for DarkSky for `w` commands.

`mapboxapikey` -- The API key for MapBox for the `DarkSky` plugin and commands.

`yourlsapiurl` -- The URL for the YOURLS instance you're going to use for short URLs.

`yourlstoken` -- The secret token to use with the YOURLS instance, we're avoiding UN/PW support.

Options
-------
You can run `swissircbot.rb` with the following options:

`-c --config <path/to/config>` -- Allows you to specify a config file to load at runtime. If not specified we will look for irc.yml in the same directory as `swissircbot.rb`

`-h --help` -- Will show the help output that lists all possible command options and associated help

Running
-------
You can start the bot by running `ruby swissircbot.rb` which will launch the bot in the current shell window.

You can alternatively run the bot with an "auto-restart" feature by creating a file called `keep-alive` and running `while [ -f keep-alive ]; do ruby swissircbot.rb; sleep 3;done` which will keep the bot alive as long as the `keep-alive` file is present. You can prevent auto-restart by deleting or renaming this file.

Examples:

`ruby swissircbot.rb` -- Will launch SwissIRCBot loading the default config file of `irc.yml`

`while [-f keep-alive ]; do ruby swissircbot.rb; sleep 3; done` -- Will launch SwissIRCBot loading the default config file of `irc.yml` while also protecting the bot by auto-restarting as long as the `keep-alive` file exists alongside `swissircbot.rb`

`ruby swissircbot.rb -c freenode.yml` -- Will launch SwissIRCBot loading the config file `freenode.yml` that resides alongside `swissircbot.rb`

`while [ -f keep-alive ]; do ruby swissircbot.rb -c freenode.yml; sleep 3; done` -- Will launch SwissIRCBot loading the config file `freenode.yml` that resides alongside `swissircbot.rb` while also protecting the bot by auto-restarting as long as the `keep-alive` file exists alongside `swissircbot.rb`

NOTE: SwissIRCBot has a `.ruby-version` file to work with `rbenv` to specify the required version of Ruby to use.

Contributing
------------
If you find any bugs or would like to add any features just open an issue or pull request.

License
-------
Copyright (c) 2014 Michael Secord. See LICENSE for details.