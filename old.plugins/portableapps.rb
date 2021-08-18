class Portableapps
  include Cinch::Plugin

  set :help, <<-HELP
n/a
  This plugin implements no commands
  HELP

  set :prefix, ''

  match /(help!|help)/i, react_on: :channel, method: :pahelp

  def pahelp(m)
    if m.channel.name == "#portableapps"
      m.reply "Welcome to the PortableApps.com official chatroom. This chatroom is mostly unused now. Your best bet is to create a post on the forums: http://portableapps.com/forums", true
    end
  end
end