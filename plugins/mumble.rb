class Mumble
  include Cinch::Plugin
  include CustomHelpers

  set :help, <<-HELP
mumble
  This will provide you with the mumble server information
  HELP

  match /mumble\b(?: (.+))?/i, method: :cmumble

  def cmumble(m, nick)
    if !is_blacklisted?(m.channel, m.user.nick)
      if nick.nil?
        m.reply "mumble.gizmokid2005.com | no password", true
      else
        m.reply "#{nick}: #{m.user.nick} sends you the mumble information: mumble.gizmokid2005.com | no password"
      end
    else
      m.user.send BLMSG
    end
  end
end
