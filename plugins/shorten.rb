require 'net/http'
require 'json'

class Shorten
  include Cinch::Plugin
  include CustomHelpers

  set :help, <<-HELP
shorten <url>
  This will return a short url for the given url.
  HELP

  match /shorten (.+)/

  def execute(m, url)
    if !is_blacklisted?(m.channel, m.user.nick)
      m.reply Shorten.shorten(url), true
    else
      m.user.send BLMSG
    end
  end

  def self.shorten(url)

    uri = URI.parse("#{YOURLSURL}?signature=#{YOURLSTOKEN}&action=shorturl&format=json&url=#{url}")
    Net::HTTP.start(uri.host, uri.port, use_ssl: true) do |http|
      resp = Net::HTTP.get_response(uri)
      begin
        data = JSON.parse(resp.body)
        if data.include?('shorturl')
          return data['shorturl']
        else
          return "I've run into an unexpected error."
        end
      rescue JSON::ParserError
        return "Sorry, the API returned an invalid/missing JSON."
      end
    end
  end

end