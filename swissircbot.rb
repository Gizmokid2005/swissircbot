require 'cinch'
require 'yaml'
require 'sqlite3'

#Plugins
require_relative 'plugins/worldweather'
require_relative 'plugins/misc'
require_relative 'plugins/google'
require_relative 'plugins/wunderground'
require_relative 'plugins/shorten'
require_relative 'plugins/url_info'
require_relative 'plugins/downup'
require 'open-uri'
require 'nokogiri'
require 'cgi'

config = YAML::load(open('irc.yml'))
p config
$admin    = config['admin']
SERVER    = config['server']
NICK      = config['nick']
CHANNELS  = config['channels']
NOTADMIN  = config['notadmin']
LOGFILE   = config['logfile']
PREFIX    = config['commandprefix']
WEATHERAPIKEY    = config['weatherapikey']
GOOGLEAPIKEY     = config['googleapikey']

bot = Cinch::Bot.new do
  configure do |c|

    c.server    = SERVER
    c.nick      = NICK
    c.channels  = CHANNELS
    c.plugins.prefix = PREFIX
    c.plugins.plugins = [Wunderground,WorldWeather,Misc,Google,Shorten,UrlInfo,DownUp]

  end

  helpers do

    def is_admin?(user)
      true if $admin.include?(user.to_s)
    end

  end

  on :message, /hello #{NICK}/i do |m|
    m.reply "Hello, #{m.user.nick}!"
  end

  on :message, /^#{PREFIX}nick (.+)$/i do |m, nick|
    if is_admin?(m.user)
      bot.nick = nick
    else
      m.reply "#{m.user.nick}: #{NOTADMIN}"
    end
  end

  on :message, /^#{PREFIX}topic (.+)$/i do |m, topic|
    if is_admin?(m.user)
      m.channel.topic = topic
    else
      m.reply "#{m.user.nick}: #{NOTADMIN}"
    end
  end

  on :message, /^#{PREFIX}msg (.+?) (.+)/i do |m, who, text|
    User(who).send text
  end

  on :message, /^#{PREFIX}echo (.+)/i do |m, text|
    m.reply text
  end

  on :message, /^#{PREFIX}join (.+)/i do |m, channel|
    if is_admin?(m.user)
      bot.join(channel)
    else
      m.reply "#{m.user.nick}: #{NOTADMIN}"
    end
  end

  on :message, /^#{PREFIX}part(?: (.+))?/i do |m, channel|
    channel = channel || m.channel
    if channel
      if is_admin?(m.user)
        bot.part(channel)
      else
        m.reply "#{m.user.nick}: #{NOTADMIN}"
      end
    end
  end

  on :message, /^#{PREFIX}quit/i do |m|
    if is_admin?(m.user)
      bot.info("Received quit command from #{m.user.name}.")
      m.reply("Goodbye everyone, #{m.user.name} has told me to leave.")
      bot.quit("I have left you at the behest of #{m.user.name}. Adios!")
    else
      m.reply "#{m.user.nick}: #{NOTADMIN}"
    end
  end

  trap "SIGINT" do
    bot.log("Caught SIGINT. Stopping.")
    bot.quit
  end

  trap "SIGTERM" do
    bot.log("Caught SIGTERM. Killing.")
    bot.quit
  end

  #file = open(LOGFILE, "a")
  #file.sync = true
  #loggers.push(Cinch::Logger::FormattedLogger.new(file))
  #loggers.first.level = :info

end

bot.start