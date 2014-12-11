module CustomHelpers

  def is_supadmin?(user)
    $superadmins.include?(user.authname.to_s) && user.authed? == true
  end

  def is_admin?(user)
    $alladmins.include?(user.authname.to_s) && user.authed? == true
  end

  def is_chanadmin?(channel, user)
    $adminhash[channel].include?(user.authname.to_s) && user.authed? == true
  end

  def is_botpowerful?(channel)
    channel.opped?(bot)
  end

  def bot_nick
    bot.nick
  end

end