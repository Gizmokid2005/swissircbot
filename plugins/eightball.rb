class Eightball
  include Cinch::Plugin
  include CustomHelpers

  set :help, <<-HELP
8ball
  Returns a classic 8ball response.
  HELP

  match /8ball\b/i, method: :eightball

  def eightball(m)
    if !is_blacklisted?(m.channel, m.user.nick)
      replies = ['It is certain','As I see it, yes','Reply hazy try again','Don\'t count on it',
                 'It is decidedly so','Most likely','Ask again later','My reply is no',
                 'Without a doubt','Outlook good','Better not tell you now','My sources say no',
                 'Yes definitely','Yes','Cannot predict now','Outlook not so good',
                 'You may rely on it','Signs point to yes','Concentrate and ask again','Very doubtful']
      m.reply replies.sample(), true
    else
      m.user.send BLMSG
    end
  end

end