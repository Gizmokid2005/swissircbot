class Portableapps
  include Cinch::Plugin

  set :prefix, ''

  match /(help!|help)/i, method: :pahelp

  def pahelp(m)
    if m.channel.name == "#portableapps"
      m.reply "Welcome to the PortableApps.com official chatroom. Ask your question and someone should be able to help you shortly. If you still don't get an answer, try posting on the forums: http://portableapps.com/forums", true
    end
  end
end