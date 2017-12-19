class Simplereplies
  include Cinch::Plugin
  include CustomHelpers
  
  set :help, <<-HELP
n/a
  This plugin implements no commands.
  HELP

  match lambda { |m| /^(?:hello|hey|hi) #{m.bot.nick}/i }, use_prefix: false, method: :hello
  match lambda { |m| /^(?:thanks|thank you) #{m.bot.nick}/i }, use_prefix: false, method: :thanks
  match lambda { |m| /^#{m.bot.nick}!/i }, use_prefix: false, method: :exclaim
  match lambda { |m| /^#{m.bot.nick}: ping/i }, use_prefix: false, method: :pong
  match /ping/i, method: :pong

  def hello(m)
    if !is_blacklisted?(m.channel, m.user.nick)
      m.reply "Hello, #{m.user.nick}!"
    else
      m.user.send BLMSG
    end
  end

  def thanks(m)
    if !is_blacklisted?(m.channel, m.user.nick)
      m.reply "You're welcome, #{m.user.nick}!"
    else
      m.user.send BLMSG
    end
  end

  def exclaim(m)
    if !is_blacklisted?(m.channel, m.user.nick)
      m.reply "!", true
    else
      m.user.send BLMSG
    end
  end

  def pong(m)
    if !is_blacklisted?(m.channel, m.user.nick)
      m.reply "Pong!", true
    else
      m.user.send BLMSG
    end
  end

end