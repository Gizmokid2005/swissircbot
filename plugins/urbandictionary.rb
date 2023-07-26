require 'cgi'
require 'json'
require 'open-uri'
require_relative 'shorten'

class Urbandictionary
  include Cinch::Plugin
  include CustomHelpers

  set :help, <<-HELP
urban/ud <word>
  This will return the definition of <word> from urbandictionary.
  HELP

  match /(?:urban|ud) (.*)/i

  def execute(m, query)
    if !is_blacklisted?(m.channel, m.user.nick)
      m.reply "#{query} - #{search(query)}", true
    else
      m.user.send BLMSG
    end
  end

  private
  def search(query)

    uri = URI.parse("https://api.urbandictionary.com/v0/define?term=#{CGI.escape(query)}")
    Net::HTTP.start(uri.host, uri.port) do |h|
      resp = Net::HTTP.get_response(uri)
      obj = JSON.parse(resp.body)
      if obj['list'].empty?
        "No result"
      else
        defn = obj['list'][0]['definition'].gsub(/(\r\n)+/, ' ')
        permlnk = obj['list'][0]['permalink']
        "#{defn[0..150]} - #{Shorten.shorten(permlnk)}"
      end
    end

  rescue => e
    exception(e)
    "An exception occurred"
  end
end