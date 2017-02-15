require 'cinch'
require 'yaml'
require 'sqlite3'
require 'optparse'
require 'open-uri'
require 'nokogiri'
require 'cgi'
require 'active_support/all'

#Dynamically load and require any Helpers
Dir["helpers/*.rb"].each {|file| require_relative file }
Dir["helpers/*.rb"].each { |file| IO.foreach(file) { |p| eval("include " + p.split('module ').last.strip) unless !p.match(/^module/) }}

#Dynamically require all Plugins
Dir["plugins/*.rb"].each {|file| require_relative file }
# require_relative "plugins/help"

#Config
options = {}
optparse = OptionParser.new do |opt|

  opt.banner = "Usage: swissircbot.rb [options]"
  options[:config] = nil

  opt.on("-c", "--config CONFIG", "Read config from CONFIG") do |conf|
    if conf.nil?
      puts "You must specify a file when using the config option."
    else
      options[:config] = conf
    end
  end

  opt.on("-h", "--help", "Display this help") do
    puts opt
    exit
  end

end

begin
  optparse.parse!
rescue OptionParser::MissingArgument
  puts $!.to_s
  puts optparse
  exit
end

if options[:config]
  $conffile = options[:config]
  $confdir = File.dirname($conffile)
else
  $conffile = "irc.yml"
  $confdir = Dir.pwd
end

$config = YAML.load_file($conffile)
p $config
$alladmins       = $config['admin']['channel'].map{ |chan,user| user}.flatten.uniq
$adminhash       = $config['admin']['channel']
$superadmins     = $config['superadmin']
$moderators      = $config['moderator']
SERVER           = $config['server']
NICK             = $config['nick']
PASSWORD         = $config['password']
CHANNELS         = $config['channels']
NOTADMIN         = $config['notadmin']
NOTOPBOT         = $config['notopbot']
LOGFILE          = $config['logfile']
PREFIX           = $config['commandprefix']
WWEATHERAPIKEY   = $config['wweatherapikey']
WUWEATHERAPIKEY  = $config['wuweatherapikey']
GOOGLEAPIKEY     = $config['googleapikey']

bot = Cinch::Bot.new do
  configure do |c|

    c.server    = SERVER
    c.nick      = NICK
    c.password  = PASSWORD
    c.channels  = CHANNELS
    c.plugins.prefix = PREFIX
    c.plugins.plugins = Dir["plugins/*.rb"].map { |file| (File.basename(file, '.rb')).camelize.constantize }
    c.plugins.options[Help] = {
      :intro => "%s at your service."
    }

  end

  # Change the bot's nick
  on :message, /^[#{PREFIX}]nick (.+)$/i do |m, nick|
    if is_supadmin?(m.user)
      bot.nick = nick
    else
      m.reply NOTADMIN, true
    end
  end

  # Message the given thing (person or channel)
  on :message, /^[#{PREFIX}]msg (.+?) (.+)/i do |m, who, text|
    if is_admin?(m.user)
      User(who).send text
    else
      m.reply NOTADMIN, true
    end
  end

  # Repeat the message that was given
  on :message, /^[#{PREFIX}]echo (.+)/i do |m, text|
    m.reply text
  end

  # Join the specified channel
  on :message, /^[#{PREFIX}]join (.+)/i do |m, channel|
    if is_supadmin?(m.user)
      bot.join(channel)
    else
      m.reply NOTADMIN, true
    end
  end

  # Part the specified channel
  on :message, /^[#{PREFIX}]part(?: (.+))?/i do |m, channel|
    channel = channel || m.channel
    if channel
      if is_supadmin?(m.user)
        bot.part(channel)
      else
        m.reply NOTADMIN, true
      end
    end
  end

  # Quit IRC
  on :message, /^[#{PREFIX}]quit$/i do |m|
    if is_supadmin?(m.user)
      if m.channel.nil?
        # Don't reply to a PM.
      else
        m.reply("Goodbye everyone, #{m.user.name} has told me to leave.")
      end
      bot.info("Received quit command from #{m.user.name}.")
      bot.quit("I have left you at the behest of #{m.user.name}. Adios!")
    else
      m.reply NOTADMIN, true
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