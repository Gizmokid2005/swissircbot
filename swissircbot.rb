require 'cinch'
require 'open-uri'
require 'nokogiri'
require 'cgi'
require 'yaml'
require 'sqlite3'

#Plugins
require_relative 'plugins/worldweather'

config = YAML::load(open('irc.yml'))
p config
SERVER    = config['server']
NICK      = config['nick']
CHANNELS  = config['channels']
NOTADMIN  = config['notadmin']
APIKEY    = config['apikey']
LOGFILE   = config['logfile']
$admin    = config['admin']

bot = Cinch::Bot.new do
  configure do |c|

    c.server    = SERVER
    c.nick      = NICK
    c.channels  = CHANNELS
    c.plugins.plugins = [Cinch::WorldWeather]

  end

  helpers do

    def is_admin?(user)
      true if $admin.include?(user.to_s)
    end

  end

  on :message, /hello #{NICK}/i do |m|
    m.reply "Hello, #{m.user.nick}!"
  end

  on :message, /^!nick (.+)$/i do |m, nick|
    if is_admin?(m.user)
      bot.nick = nick
    else
      m.reply NOTADMIN
    end
  end

  on :message, /^!topic (.+)$/i do |m, topic|
    if is_admin?(m.user)
      m.channel.topic = topic
    else
      m.reply NOTADMIN
    end
  end

  on :message, /^!msg (.+?) (.+)/i do |m, who, text|
    User(who).send text
  end

  on :message, /^!echo (.+)/i do |m, text|
    m.reply text
  end

  on :message, /^!join (.+)/i do |m, channel|
    if is_admin?(m.user)
      bot.join(channel)
    else
      m.reply NOTADMIN
    end
  end

  on :message, /^!part(?: (.+))?/i do |m, channel|
    channel = channel || m.channel
    if channel
      if is_admin?(m.user)
        bot.part(channel)
      else
        m.reply NOTADMIN
      end
    end
  end

  on :message, /^!quit/i do |m|
    if is_admin?(m.user)
      bot.info("Received quit command from #{m.user.name}.")
      m.reply("Goodbye everyone, #{m.user.name} has told me to leave.")
      bot.quit("I have left you at the behest of #{m.user.name}. Adios!")
    else
      m.reply NOTADMIN
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