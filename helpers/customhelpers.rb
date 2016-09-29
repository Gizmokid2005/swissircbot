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
    $adminhash[channel].include?(user.authname.to_s) && user.authed? == true
  end

  # Is the bot powerful (opped)?
  def is_botpowerful?(channel)
    channel.opped?(bot)
  end

  def bot_nick
    bot.nick
  end

end