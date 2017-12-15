class SimpleReplies
  include Cinch::Plugin
  include CustomHelpers
  
  set :help, <<-HELP
n/a
  This plugin implements no commands.
  HELP

  set :prefix, ''

  match lambda { |m| /(?:hello|hey|hi) #{m.bot.nick}/i }, method: :hello
  match lambda { |m| /(?:thanks|thank you) #{m.bot.nick}/i }, method: :thanks
  match lambda { |m| /#{m.bot.nick}!/i }, method: :exclaim
  match lambda { |m| /#{m.bot.nick}: ping/i }, method: :pong

  def hello(m)
    m.reply "Hello, #{m.user.nick}!"
  end

  def thanks(m)
    m.reply "You're welcome, #{m.user.nick}!"
  end

  def exclaim(m)
    m.reply "!", true
  end

  def pong(m)
    m.reply "Pong!", true
  end

end