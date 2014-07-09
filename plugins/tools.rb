class Tools
  include Cinch::Plugin
  include CustomHelpers

  match /kick (\S+)(?: (.+))?/i, method: :ckick
  match /r (.+?)/i, method: :crem
  match /ban (\S+)(?: (.+))?/i, method: :cban
  match /unban (.+)/i, method: :cunban
  match /mute (.+)/i, method: :cmute
  match /unmute (.+)/i, method: :cunmute
  match /addadmin (\S+)(?: (.+))?/i, method: :caddadmin
  match /remadmin (\S+)(?: (.+))?/i, method: :cremadmin

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
    if is_chanadmin?(m.channel, m.user) && is_botpowerful?(m.channel)
      User('ChanServ').send("quiet #{m.channel} #{nick}")
    elsif !is_chanadmin?(m.channel, m.user)
      m.reply "#{m.user.nick}: #{NOTADMIN}"
    elsif !is_botpowerful?(m.channel)
      m.reply "#{m.user.nick}: #{NOTOPBOT}"
    end
  end

  def cunmute(m, nick)
    nick = User(nick)
    if is_chanadmin?(m.channel, m.user) && is_botpowerful?(m.channel)
      User('ChanServ').send("unquiet #{m.channel} #{nick}")
    elsif !is_chanadmin?(m.channel, m.user)
      m.reply "#{m.user.nick}: #{NOTADMIN}"
    elsif !is_botpowerful?(m.channel)
      m.reply "#{m.user.nick}: #{NOTOPBOT}"
    end
  end

  def caddadmin(m, nick, channel)
    if is_admin?(m.user)
      channel = m.channel if channel.nil?
      $adminhash[channel] << nick
      $config['admin']['channel'] = $adminhash
      File.open('irctest.yml', 'wb') { |f| f.write $config.to_yaml }
      m.reply "#{m.user.nick}: #{nick} has been added as an admin for #{channel}."
    else
      m.reply "#{m.user.nick}: #{NOTADMIN}"
    end
  end

  def cremadmin(m, nick, channel)
    if is_admin?(m.user)
      channel = m.channel if channel.nil?
      $adminhash[channel].delete nick
      $config['admin']['channel'] = $adminhash
      File.open('irctest.yml', 'wb') { |f| f.write $config.to_yaml }
      m.reply "#{m.user.nick}: #{nick} has been removed as an admin for #{channel}."
    else
      m.reply "#{m.user.nick}: #{NOTADMIN}"
    end
  end

end