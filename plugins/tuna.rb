class Tuna
  include Cinch::Plugin
  include CustomHelpers
  include DBHelpers

  set :help, <<-HELP
tuna
  This will return a random imgur link that Tunabrain has shared
  HELP

  listen_to :message, method: :ctuna
  match /tuna/i, method: :ctrandom
  match /addtuna (.+)/i, method: :caddtuna

  def ctuna(m)
    if m.user.nick.downcase == 'tunabrain' && m.message.downcase.starts_with?("https://i.imgur.com/")
      if !db_tuna_check(m.message.strip).any?
        db_tuna_add(m.message.strip)
      end
    end
  end

  def ctrandom(m)
    if !is_blacklisted?(m.channel, m.user.nick)
      tuna = db_tuna_geturl
      if tuna.any?
        m.reply tuna[0][1], true
      else
        m.reply "Sorry, I cannot find any URLs", true
      end
    end
  end

  def caddtuna(m, url)
    if !is_blacklisted?(m.channel, m.user.nick)
      if db_tuna_check(url.strip).any?
        m.reply "I already have that URL.", true
      else
        if db_tuna_add(url.strip) == 1
          m.reply "URL added", true
        else
          m.reply "Sorry, couldn't add that URL boss", true
        end
      end
    end
  end

end