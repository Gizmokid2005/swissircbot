class Misc
  include Cinch::Plugin

  match /4d3d3d3(?: (.+))?/i, method: :c4d3d3d3
  match /yo(?: (.+))?/i, method: :cyo
  match /numa(?: (.+))?/i, method: :cnuma

  def c4d3d3d3(m, nick) #OhGodWhy
    if nick.nil?
      m.reply "https://www.youtube.com/watch?v=XWX4GUYGQXQ", true
    else
      m.reply "#{nick}: #{m.user.nick} points you to https://www.youtube.com/watch?v=XWX4GUYGQXQ"
    end
  end

  def cyo(m, nick) #Sigh...the things I do for you people.
    if nick.nil?
      m.reply "Yo!", true
    else
      m.reply "#{nick}: #{m.user.nick} says Yo!"
    end
  end

  def cnuma(m, nick) #AgeOldAwesome!
    if nick.nil?
      m.reply "https://www.youtube.com/watch?v=KmtzQCSh6xk", true
    else
      m.reply "#{nick}: #{m.user.nick} points you to https://www.youtube.com/watch?v=KmtzQCSh6xk"
    end
  end

end