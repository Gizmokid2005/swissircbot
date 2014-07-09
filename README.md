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


Contributing
------------
If you find any bugs or would like to add any features just open an issue or pull request.

License
-------
Copyright (c) 2014 Michael Secord. See LICENSE for details.