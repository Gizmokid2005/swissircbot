class Blacklist
  include Cinch::Plugin
  include CustomHelpers

  set :help, <<-HELP
No help set yet.
  HELP

  match /bl add (\S+)(?: (.+))?/i, method: :add_entry
  match /bl remove (\S+)(?: (.+))?/i, method: :remove_entry
  match /bl list(?: (.+))?/i, method: :list_blacklist
  match /bl reload/i, method: :reload

  def add_entry(m, nick, channel)
    reload_blacklist
    if !is_blacklisted?(m.channel, m.user.nick)
      channel = m.channel if channel.nil?
      if is_chanadmin?(channel, m.user) || is_supadmin?(m.user)
        if $blhash.nil? || $blhash[channel].nil?
          $blhash[channel] = []
        end
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
    reload_blacklist
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
    reload_blacklist
    if !is_blacklisted?(m.channel, m.user.nick)
      channel = m.channel if channel.nil?
      if is_supadmin?(m.user) || is_admin?(m.user) || is_chanadmin?(channel, m.user)
        if  $blhash.nil?|| $blhash[channel].nil?
          m.reply "There is no current blacklist for #{channel}.", true
        elsif $blhash[channel].empty?
          m.reply "There is no current blacklist for #{channel}.", true
        else
          m.reply "The current blacklist for #{channel} is #{$blhash[channel]}.", true
        end
      else
        m.reply NOTADMIN, true
      end
    else
      m.user.send BLMSG
    end
  end

  def reload(m)
    if !is_blacklisted?(m.channel, m.user.nick)
      if is_supadmin?(m.user) || is_admin?(m.user) || is_chanadmin?(channel, m.user)
        if reload_blacklist
          m.reply "Reload complete boss!", true
        else
          m.reply "Sorry, I couldn't do that.", true
        end
      else
        m.reply NOTADMIN, true
      end
    else
      m.user.send BLMSG
    end
  end

end