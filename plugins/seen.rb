class Seen
  include Cinch::Plugin

  set :help, <<-HELP
seen <user>
  This returns the last time I saw user speak.
  HELP

  listen_to :message, method: :i_spy

  match /seen (.+)/i, method: :seen

  def seen(m, who)
    if who == bot.nick
      m.reply "I'm right here.", true
    elsif who == m.user.nick
      m.reply "That's you!", true
    else
      i_see = seen_who(who)
      if i_see.empty?
        m.reply "Sorry, I haven't seen #{who}.", true
      else
          m.reply "I last saw #{who} at #{i_see[0][1]} on #{i_see[0][0]}", true
      end
    end
  end

  def i_spy(m)
    i_see(m.user.nick, m.channel.to_s, DateTime.now)
  end

end