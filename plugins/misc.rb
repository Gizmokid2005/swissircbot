class Misc
  include Cinch::Plugin

  match /4d3d3d3/

  def execute(m)
    m.reply "#{m.user.nick}: https://www.youtube.com/watch?v=XWX4GUYGQXQ" #OhGodWhy
  end

end