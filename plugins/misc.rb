class Misc
  include Cinch::Plugin

  match /4d3d3d3 (.+)/, method: :c4d3d3d3
  match /yo (.+)/, method: :cyo

  def c4d3d3d3(m)
    m.reply "#{m.user.nick}: https://www.youtube.com/watch?v=XWX4GUYGQXQ" #OhGodWhy
  end

  def cyo(m)
    m.reply "#{m.user.nick}: Yo!" #Sigh...the things I do for you people.
  end

end