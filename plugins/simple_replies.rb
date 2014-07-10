class SimpleReplies
  include Cinch::Plugin
  include CustomHelpers

  set :prefix, ''

  match lambda { |m| /hello #{m.bot.nick}/ }, method: :hello
  match lambda { |m| /(?:thanks|thank you) #{m.bot.nick}/ }, method: :thanks

  def hello(m)
    m.reply "Hello, #{m.user.nick}!"
  end

  def thanks(m)
    m.reply "You're welcome, #{m.user.nick}!"
  end

end