require 'yaml'

module CustomHelpers

  # Is the user a super-admin for the bot?
  def is_supadmin?(user)
    $superadmins.include?(user.authname.to_s) && user.authed? == true
  end

  # Is the user an admin for the bot at all?
  def is_admin?(user)
    $alladmins.include?(user.authname.to_s) && user.authed? == true
  end

  # Is this user a moderator for this bot at all?
  def is_mod?(user)
    $moderators.include?(user.authname.to_s) && user.authed? == true
  end

  # Is this user an admin for this channel?
  def is_chanadmin?(channel, user)
    $adminhash[channel].include?(user.authname.to_s) && user.authed? == true unless $adminhash[channel].nil?
  end

  # What are the users roles?
  def userroles(channel, user)
    roles = Array.new()
    if is_supadmin?(user)
      roles << 'Super Admin'
    end
    if is_admin?(user)
      roles << 'Admin'
    end
    if is_chanadmin?(channel,user)
      roles << 'ChanAdmin'
    end
    if is_mod?(user)
      roles << 'Mod'
    end
    return roles
  end

  # Is the user blacklisted?
  def is_blacklisted?(channel, user)
    reload_blacklist
    if $blhash.nil?
      return false
    else
      $blhash[channel].include?(user) unless $blhash[channel].nil?
    end
  end

  # Is the bot powerful (opped)?
  def is_botpowerful?(channel)
    channel.opped?(bot)
  end

  def bot_nick
    bot.nick
  end

  # Reload the blacklist
  def reload_blacklist
    $config = YAML.load_file($conffile)
    $blhash = $config['blacklist']['channel']
  end

  # Pluralize
  def pluralize(n, singular, plural=nil)
    if n == 1
      "1 #{singular}"
    elsif plural
      "#{n} #{plural}"
    else
      "#{n} #{singular}s"
    end
  end

end