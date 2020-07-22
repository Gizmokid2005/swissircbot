require 'date'

class Wednesday
  include Cinch::Plugin
  include CustomHelpers

  set :help, <<-HELP
case wednesday
  This will return a random Wednesday URL, only on Wednesday. Don't test this theory.
addwednesday <url>
  This will add the <url> to the rotation for the wednesday command.
remwednesday <url>
  This will remove the <url> from the rotation for the wednesday command.
end
  HELP

  match /wednesday/i, method: :cwednesday
  match /addwednesday (.+)/i, method: :caddwednesday
  match /remwednesday (.+)/i, method: :cremwednesday

  def cwednesday(m)
    if !is_blacklisted?(m.channel, m.user.nick)
      m.reply geturl
    else
      m.user.send BLMSG
    end
  end

  def caddwednesday(m, url)
    if !is_blacklisted?(m.channel, m.user.nick)
      if addurl(url)
        m.reply "URL added", true
      else
        m.reply "Sorry, couldn't add that URL.", true
      end
    else
      m.user.send BLMSG
    end
  end

  def cremwednesday(m, url)
    if !is_blacklisted?(m.channel, m.user.nick)
      if remurl(url)
        m.reply "URL removed", true
      else
        m.reply "Sorry, couldn't remove that URL.", true
      end
    else
      m.user.send BLMSG
    end
  end

  private

  def geturl()
    urls = File.readlines('wednesdayurls.txt').map(&:chomp)
    return urls.sample
  end

  def addurl(url)
    File.write('wednesdayurls.txt', "\n#{url}", mode: "a")
  end

  def remurl(url)
    urls = File.readlines('wednesdayurls.txt').map(&:chomp)
    urls.delete("#{url}")
    File.write('wednesdayurls.txt', urls.join("\n"), mode: "w+")
  end

end