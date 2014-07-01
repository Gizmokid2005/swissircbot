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
$alladmins       = config['admin']['channel'].map{ |chan,user| user}.flatten.uniq
$adminhash       = config['admin']['channel']
SERVER           = config['server']
NICK             = config['nick']
PASSWORD         = config['password']
CHANNELS         = config['channels']
NOTADMIN         = config['notadmin']
NOTOPBOT         = config['notopbot']
LOGFILE          = config['logfile']
PREFIX           = config['commandprefix']
WEATHERAPIKEY    = config['weatherapikey']
GOOGLEAPIKEY     = config['googleapikey']

bot = Cinch::Bot.new do
  configure do |c|

    c.server    = SERVER
    c.nick      = NICK
    c.password  = PASSWORD
    c.channels  = CHANNELS
    c.plugins.prefix = PREFIX
    c.plugins.plugins = [Wunderground,WorldWeather,Misc,Google,Shorten,UrlInfo,DownUp]

  end

  helpers do

    def is_admin?(user)
      $alladmins.include?(user.authname.to_s) && user.authed? == true
    end

    def is_chanadmin?(channel, user)
      $adminhash[channel].include?(user.authname.to_s) && user.authed? == true
    end

    def is_botpowerful?(channel)
      channel.opped?(bot)
    end

  end

  # Simple Hello Reply
  on :message, /hello #{NICK}/i do |m|
    m.reply "Hello, #{m.user.nick}!"
  end

  # Change the bot's nick
  on :message, /^[#{PREFIX}]nick (.+)$/i do |m, nick|
    if is_admin?(m.user)
      bot.nick = nick
    else
      m.reply "#{m.user.nick}: #{NOTADMIN}"
    end
  end

  # Change the topic of the current channel
  on :message, /^[#{PREFIX}]topic (.+)$/i do |m, topic|
    if m.channel.nil?
      m.reply "Silly #{m.user.nick}: This isn't a channel!"
    else
      if is_chanadmin?(m.channel,m.user) && is_botpowerful?(m.channel)
        m.channel.topic = topic
      elsif !is_chanadmin?(m.channel,m.user)
        m.reply "#{m.user.nick}: #{NOTADMIN}"
      elsif !is_botpowerful?(m.channel)
        m.reply "#{m.user.nick}: #{NOTOPBOT}"
      end
    end
  end

  # Message the given thing (person or channel)
  on :message, /^[#{PREFIX}]msg (.+?) (.+)/i do |m, who, text|
    User(who).send text
  end

  # Repeat the message that was given
  on :message, /^[#{PREFIX}]echo (.+)/i do |m, text|
    m.reply text
  end

  # Join the specified channel
  on :message, /^[#{PREFIX}]join (.+)/i do |m, channel|
    if is_admin?(m.user)
      bot.join(channel)
    else
      m.reply "#{m.user.nick}: #{NOTADMIN}"
    end
  end

  # Part the specified channel
  on :message, /^[#{PREFIX}]part(?: (.+))?/i do |m, channel|
    channel = channel || m.channel
    if channel
      if is_admin?(m.user)
        bot.part(channel)
      else
        m.reply "#{m.user.nick}: #{NOTADMIN}"
      end
    end
  end

  # Quit IRC
  on :message, /^[#{PREFIX}]quit/i do |m|
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