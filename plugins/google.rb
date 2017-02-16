require 'nokogiri'
require 'cgi'
require 'open-uri'

class Google
  include Cinch::Plugin

  set :help, <<-HELP
google <term>
  This will return the first google result for term.
  HELP

  match /google (.+)/i

  def execute(m, query)
    m.reply search(query), true
  end

  def search(query)

    url = "http://www.google.com/search?q=#{CGI.escape(query)}&ie=utf-8&oe=utf-8"
    @res = Nokogiri.parse(open(url.to_s).read).at("h3.r")
    return "Google is stumped: #{url}" if @res.nil?
    CGI.unescape_html "#{title} - #{URI.unescape(link)} from: #{url}"

  end

  def title
    @res.text || "Unable to find title"
  end

  def link
    @link = begin
              href = @res.at('a')[:href] || "Unable to parse link"
              href.split("/url?q=").last.split("&").first
            end
  end

end
