class Blacklist
  include Cinch::Plugin
  include CustomHelpers

  set :help, <<-HELP

  HELP

  match /bl add (\S+)(?: (.+))?/i, method: :add_entry
  match /bl remove (\S+)(?: (.+))?/i, method: :remove_entry
  match /bl list(?: (.+))?/i, method: :list_blacklist

  def add_entry(m, nick, channel)
    if !is_blacklisted?(m.channel, m.user.nick)
      channel = m.channel if channel.nil?
      if is_chanadmin?(channel, m.user) || is_supadmin?(m.user)
        $blhash[channel] << nick
        $config['blacklist']['channel'] = $blhash
        File.open($conffile, 'wb') { |f| f.write $config.to_yaml }
        m.reply "#{nick} has been blacklisted from using commands on #{channel}.", true
      else
        m.reply NOTADMIN, true
      end
    else
      m.user.send BLMSG
    end
  end

  def remove_entry(m, nick, channel)
    if !is_blacklisted?(m.channel, m.user.nick)
      channel = m.channel if channel.nil?
      if is_chanadmin?(channel, m.user) || is_supadmin?(m.user)
        $blhash[channel].delete nick
        $config['blacklist']['channel'] = $blhash
        File.open($conffile, 'wb') { |f| f.write $config.to_yaml }
        m.reply "#{nick} has been un-blacklisted from using commands on #{channel}.", true
      else
        m.reply NOTADMIN, true
      end
    else
      m.user.send BLMSG
    end
  end

  def list_blacklist(m, channel)
    if !is_blacklisted?(m.channel, m.user.nick)
      channel = m.channel if channel.nil?
      if is_supadmin?(m.user) || is_admin?(m.user) || is_chanadmin?(channel, m.user)
        m.reply "The current blacklist for #{channel} is #{$blhash[channel]}.", true
      else
        m.reply NOTADMIN, true
      end
    else
      m.user.send BLMSG
    end
  end


end