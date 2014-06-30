require 'nokogiri'
require 'cgi'
require 'open-uri'

class Google
  include Cinch::Plugin

  match /google (.+)/i

  def search(query)

    url = "http://www.google.com/search?q=#{CGI.escape(query)}"

    res = Nokogiri.parse(open(url.to_s).read).at("h3.r")
    if res.text
      title = res.text
    else
      title = "Unable to find title"
    end
    if res.at('a')[:href]
      link = res.at('a')[:href].split("/url?q=").last.split("&").first
    else
      link = "Unable to parse link"
    end
    CGI.unescape_html "#{title} - #{link}"

  end

  def execute(m,query)
    m.reply "#{m.user.nick}: #{search(query)}"
  end

end