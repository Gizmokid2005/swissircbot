require 'date'

class Mydudes
  include Cinch::Plugin
  include CustomHelpers

  set :help, <<-HELP
today
  This will tell you what day it is.
wednesday
  This will return a random Wednesday URL, only on Wednesday. Don't test this theory.
addwednesday <url>
  This will add the <url> to the rotation for the wednesday command.
remwednesday <url>
  This will remove the <url> from the rotation for the wednesday command.
friday
  This will return a random Friday URL, only on Friday. Don't test this theory.
addfriday <url>
  This will add the <url> to the rotation for the friday command.
remfriday <url>
  This will remove the <url> from the rotation for the friday command.
  HELP

  match /today\b/i, method: :ctoday
  match /wednesday\b/i, method: :cwednesday
  match /addwednesday (.+)/i, method: :caddwednesday
  match /remwednesday (.+)/i, method: :cremwednesday
  match /friday\b/i, method: :cfriday
  match /addfriday (.+)/i, method: :caddfriday
  match /remfriday (.+)/i, method: :cremfriday
  match /mydudes?\b/i, method: :cmydudes

  def ctoday(m)
    if !is_blacklisted?(m.channel, m.user.nick)
      m.reply "It is #{Date.today.strftime("%A")} my dude.", true
    else
      m.user.send BLMSG
    end
  end

  def cwednesday(m)
    if Date.today.cwday == 3
      if !is_blacklisted?(m.channel, m.user.nick)
        m.reply geturl, true
      else
        m.user.send BLMSG
      end
    else
      User("ChanServ").send("op #{m.channel} #{m.bot.nick}")
      sleep 0.25
      m.user.notice "It is #{Date.today.strftime("%A")} my dude."
      m.channel.kick(m.user, "It is #{Date.today.strftime("%A")} my dude.")
      User("ChanServ").send("deop #{m.channel} #{m.bot.nick}")
    end
  end

  def caddwednesday(m, url)
    url = url.strip
    if !is_blacklisted?(m.channel, m.user.nick)
      if File.readlines('wednesdayurls.txt').map(&:chomp).include?(url)
        m.reply "I already have that one.", true
      else
        if addurl(url)
          m.reply "URL added", true
        else
          m.reply "Sorry, couldn't add that URL.", true
        end
      end
    else
      m.user.send BLMSG
    end
  end

  def cremwednesday(m, url)
    url = url.strip
    if !is_blacklisted?(m.channel, m.user.nick)
      if File.readlines('wednesdayurls.txt').map(&:chomp).include?(url) && remurl(url)
        m.reply "URL removed", true
      else
        m.reply "Sorry, couldn't remove that URL.", true
      end
    else
      m.user.send BLMSG
    end
  end

  def cfriday(m)
    if Date.today.cwday == 5
      if !is_blacklisted?(m.channel, m.user.nick)
        m.reply getfriurl, true
      else
        m.user.send BLMSG
      end
    else
      User("ChanServ").send("op #{m.channel} #{m.bot.nick}")
      sleep 0.25
      m.user.notice "It is #{Date.today.strftime("%A")} my dude."
      m.channel.kick(m.user, "It is #{Date.today.strftime("%A")} my dude.")
      User("ChanServ").send("deop #{m.channel} #{m.bot.nick}")
    end
  end

  def caddfriday(m, url)
    url = url.strip
    if !is_blacklisted?(m.channel, m.user.nick)
      if File.readlines('fridayurls.txt').map(&:chomp).include?(url)
        m.reply "I already have that one.", true
      else
        if addfriurl(url)
          m.reply "URL added", true
        else
          m.reply "Sorry, couldn't add that URL.", true
        end
      end
    else
      m.user.send BLMSG
    end
  end

  def cremfriday(m, url)
    url = url.strip
    if !is_blacklisted?(m.channel, m.user.nick)
      if File.readlines('fridayurls.txt').map(&:chomp).include?(url) && remfriurl(url)
        m.reply "URL removed", true
      else
        m.reply "Sorry, couldn't remove that URL.", true
      end
    else
      m.user.send BLMSG
    end
  end

  def cmydudes(m)
    if Date.today.cwday == 3
      cwednesday(m)
    else
      ctoday(m)
    end
  end

  private

  def geturl()
    urls = File.readlines('wednesdayurls.txt').map(&:chomp)
    newurl = @lastwedurl
    while @lastwedurl == newurl || newurl.empty?
      newurl = urls.sample
    end
    @lastwedurl = newurl
    return @lastwedurl
  end

  def addurl(url)
    File.write('wednesdayurls.txt', "\n#{url}", mode: "a")
  end

  def remurl(url)
    urls = File.readlines('wednesdayurls.txt').map(&:chomp)
    urls.delete("#{url}")
    File.write('wednesdayurls.txt', urls.join("\n"), mode: "w+")
  end

  def getfriurl()
    urls = File.readlines('fridayurls.txt').map(&:chomp)
    newurl = @lastfriurl
    while @lastfriurl == newurl || newurl.empty?
      newurl = urls.sample
    end
    @lastfriurl = newurl
    return @lastfriurl
  end

  def addfriurl(url)
    File.write('fridayurls.txt', "\n#{url}", mode: "a")
  end

  def remfriurl(url)
    urls = File.readlines('fridayurls.txt').map(&:chomp)
    urls.delete("#{url}")
    File.write('fridayurls.txt', urls.join("\n"), mode: "w+")
  end

end