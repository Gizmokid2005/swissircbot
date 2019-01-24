require 'net/http'
require 'json'

class Pirate
  include Cinch::Plugin
  include CustomHelpers

  set :help, <<-HELP
pirate <text>
  This will translate the text into pirate speak.
  HELP

  match /pirate (.+)/i

  def execute(m, text)
    if !is_blacklisted?(m.channel, m.user.nick)
      uri = URI.parse("http://isithackday.com/arrpi.php?text=#{CGI.escape(text)}&format=json")
      Net::HTTP.start(uri.host, uri.port) do |h|
        resp = Net::HTTP.get_response(uri)
        @pirate = JSON.parse(resp.body)
      end

      m.reply @pirate["translation"]["pirate"]
    else
      m.user.send BLMSG
    end
  end

end
