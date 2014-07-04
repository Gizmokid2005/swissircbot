class Tools
  include Cinch::Plugin
  include CustomHelpers

  match /kick (\S+)(?: (.+))?/i, method: :ckick
  match /r (.+?)/i, method: :crem
  match /ban (\S+)(?: (.+))?/i, method: :cban
  match /unban (.+)/i, method: :cunban
  match /mute (.+)/i, method: :cmute
  match /unmute (.+)/i, method: :cunmute

  def ckick(m, nick, reason)
    if is_chanadmin?(m.channel, m.user) && is_botpowerful?(m.channel)
      m.channel.kick(nick, reason)
    elsif !is_chanadmin?(m.channel, m.user)
      m.reply "#{m.user.nick}: #{NOTADMIN}"
    elsif !is_botpowerful?(m.channel)
      m.reply "#{m.user.nick}: #{NOTOPBOT}"
    end
  end

  def crem(m, nick)
    if is_chanadmin?(m.channel, m.user) && is_botpowerful?(m.channel)
      m.channel.remove(nick, reason)
    elsif !is_chanadmin?(m.channel,m.user)
      m.reply "#{m.user.nick}: #{NOTADMIN}"
    elsif !is_botpowerful?(m.channel)
      m.reply "#{m.user.nick}: #{NOTOPBOT}"
    end
  end

  def cban(m, nick, reason)
    nick = User(nick)
    if is_chanadmin?(m.channel, m.user) && is_botpowerful?(m.channel)
      m.channel.ban(nick.mask)
      m.channel.kick(nick, reason)
    elsif !is_chanadmin?(m.channel, m.user)
      m.reply "#{m.user.nick}: #{NOTADMIN}"
    elsif !is_botpowerful?(m.channel)
      m.reply "#{m.user.nick}: #{NOTOPBOT}"
    end
  end

  def cunban(m, nick)
    nick = User(nick)
    if is_chanadmin?(m.channel, m.user) && is_botpowerful?(m.channel)
      m.channel.unban(nick.mask)
    elsif !is_chanadmin?(m.channel, m.user)
      m.reply "#{m.user.nick}: #{NOTADMIN}"
    elsif !is_botpowerful?(m.channel)
      m.reply "#{m.user.nick}: #{NOTOPBOT}"
    end
  end

  def cmute(m, nick)
    nick = User(nick)
    User('ChanServ').send("quiet #{m.channel} #{nick}")
  end

  def cunmute(m, nick)
    nick = User(nick)
    User('ChanServ').send("unquiet #{m.channel} #{nick}")
  end

end