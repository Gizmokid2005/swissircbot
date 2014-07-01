module CustomHelpers

  def is_admin?(user)
    $alladmins.include?(user.authname.to_s) && user.authed? == true
  end

  def is_chanadmin?(channel, user)
    $adminhash[channel].include?(user.authname.to_s) && user.authed? == true
  end

  def is_botpowerful?(channel)
    channel.opped?(bot)
  end

end