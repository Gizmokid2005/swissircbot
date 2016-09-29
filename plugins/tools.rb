class Tools
  include Cinch::Plugin
  include CustomHelpers

  match /kick (\S+)(?: (.+))?/i, method: :ckick
  match /r (.+?)/i, method: :crem
  match /ban (\S+)(?: (.+))?/i, method: :cban
  match /unban (.+)/i, method: :cunban
  match /mute (.+)/i, method: :cmute
  match /unmute (.+)/i, method: :cunmute
  match /op (.+)/i, method: :cop
  match /deop (.+)/i, method: :cdeop
  match /addadmin (\S+)(?: (.+))?/i, method: :caddadmin
  match /remadmin (\S+)(?: (.+))?/i, method: :cremadmin
  match /addmod (\S+)(?: (.+))?/i, method: :caddmod
  match /remmod (\S+)(?: (.+))?/i, method: :cremmod
  match /topic (.+)$/i, method: :ctopic

  # Kick a user from a channel for a specific reason (or no reason)
  def ckick(m, nick, reason)
    if is_chanadmin?(m.channel, m.user) && is_botpowerful?(m.channel)
      m.channel.kick(nick, reason)
    elsif !is_chanadmin?(m.channel, m.user)
      m.reply NOTADMIN, true
    elsif !is_botpowerful?(m.channel)
      m.reply NOTOPBOT, true
    end
  end

  # Remove a user from a channel, similar to kick, but silent
  def crem(m, nick)
    if is_chanadmin?(m.channel, m.user) && is_botpowerful?(m.channel)
      m.channel.remove(nick, reason)
    elsif !is_chanadmin?(m.channel,m.user)
      m.reply NOTADMIN, true
    elsif !is_botpowerful?(m.channel)
      m.reply NOTOPBOT, true
    end
  end

  # Ban a user from a channel for a reason
  def cban(m, nick, reason)
    nick = User(nick)
    if is_chanadmin?(m.channel, m.user) && is_botpowerful?(m.channel)
      m.channel.ban(nick.mask)
      m.channel.kick(nick, reason)
    elsif !is_chanadmin?(m.channel, m.user)
      m.reply NOTADMIN, true
    elsif !is_botpowerful?(m.channel)
      m.reply NOTOPBOT, true
    end
  end

  # Unban a user from a channel
  def cunban(m, nick)
    nick = User(nick)
    if is_chanadmin?(m.channel, m.user) && is_botpowerful?(m.channel)
      m.channel.unban(nick.mask)
    elsif !is_chanadmin?(m.channel, m.user)
      m.reply NOTADMIN, true
    elsif !is_botpowerful?(m.channel)
      m.reply NOTOPBOT, true
    end
  end

  # Mute a user in a channel
  def cmute(m, nick)
    nick = User(nick)
    if is_chanadmin?(m.channel, m.user) && is_botpowerful?(m.channel)
      User('ChanServ').send("quiet #{m.channel} #{nick}")
    elsif !is_chanadmin?(m.channel, m.user)
      m.reply NOTADMIN, true
    elsif !is_botpowerful?(m.channel)
      m.reply NOTOPBOT, true
    end
  end

  # UnMute a user in a channel
  def cunmute(m, nick)
    nick = User(nick)
    if is_chanadmin?(m.channel, m.user) && is_botpowerful?(m.channel)
      User('ChanServ').send("unquiet #{m.channel} #{nick}")
    elsif !is_chanadmin?(m.channel, m.user)
      m.reply NOTADMIN, true
    elsif !is_botpowerful?(m.channel)
      m.reply NOTOPBOT, true
    end
  end

  # Op a user in a channel
  def cop(m, nick)
    nick = User(nick)
    if is_chanadmin?(m.channel, m.user) && is_botpowerful?(m.channel)
      m.channel.op(m.channel, nick)
    elsif !is_chanadmin?(m.channel, m.user)
      m.reply NOTADMIN, true
    elsif !is_botpowerful?(m.channel)
      m.reply NOTOPBOT, true
    end
  end

  # DeOp a user in a channel
  def cdeop(m, nick)
    nick = User(nick)
    if is_chanadmin?(m.channel, m.user) && is_botpowerful?(m.channel)
      m.channel.deop(m.channel, nick)
    elsif !is_chanadmin?(m.channel, m.user)
      m.reply NOTADMIN, true
    elsif !is_botpowerful?(m.channel)
      m.reply NOTOPBOT, true
    end
  end

  # Add a user as an admin of the bot for a specific channel (or current channel if none specified)
  def caddadmin(m, nick, channel)
    channel = m.channel if channel.nil?
    if is_chanadmin?(channel, m.user)
      $adminhash[channel] << nick
      $config['admin']['channel'] = $adminhash
      File.open($conffile, 'wb') { |f| f.write $config.to_yaml }
      m.reply "#{nick} has been added as an admin for #{channel}.", true
    else
      m.reply NOTADMIN, true
    end
  end

  # Remove a user as an admin of the bot for the specific channel (or current channel if none specified)
  def cremadmin(m, nick, channel)
    channel = m.channel if channel.nil?
    if is_chanadmin?(channel, m.user)
      $adminhash[channel].delete nick
      $config['admin']['channel'] = $adminhash
      File.open($conffile, 'wb') { |f| f.write $config.to_yaml }
      m.reply "#{nick} has been removed as an admin for #{channel}.", true
    else
      m.reply NOTADMIN, true
    end
  end

  # Add a user as a moderator of this bot
  def caddmod(m, nick)
    if is_supadmin?(m.user)
      $moderators << nick
      $config['moderator'] = $moderators
      File.open($conffile, 'wb') { |f| f.write $config.to_yaml }
      m.reply "#{nick} has been added as a moderator.", true
    else
      m.reply NOTADMIN, true
    end
  end

  # Remove a user as a moderator of this bot
  def cremmod(m, nick)
    if is_supadmin?(m.user)
      $moderators.delete nick
      $config['moderator'] = $moderators
      File.open($conffile, 'wb') { |f| f.write $config.to_yaml }
      m.reply "#{nick} has been removed as a moderator.", true
    else
      m.reply NOTADMIN, true
    end
  end

  # Change the topic of the current channel
  def ctopic(m, topic)
    if m.channel.nil?
      m.reply "Silly #{m.user.nick}: This isn't a channel!"
    else
      if is_chanadmin?(m.channel,m.user) && is_botpowerful?(m.channel)
        m.channel.topic = topic
      elsif !is_chanadmin?(m.channel,m.user)
        m.reply NOTADMIN, true
      elsif !is_botpowerful?(m.channel)
        m.reply NOTOPBOT, true
      end
    end
  end

end