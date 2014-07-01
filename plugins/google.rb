require 'nokogiri'
require 'cgi'
require 'open-uri'

class Google
  include Cinch::Plugin

  match /google (.+)/i

  def execute(m,query)
    m.reply "#{m.user.nick}: #{search(query)}"
  end

  def search(query)

    url = "http://www.google.com/search?q=#{CGI.escape(query)}"
    @res = Nokogiri.parse(open(url.to_s).read).at("h3.r")
    CGI.unescape_html "#{title} - #{link}"

  end

  def title
    @res.text || "Unable to find title"
  end

  def link
    @link ||= begin
                href = @res.at('a')[:href] || "Unable to parse link"
                href.split("/url?q=").last.split("&").first
              end
  end

end
