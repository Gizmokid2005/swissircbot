require 'net/http'
require 'json'

class Swanson
  include Cinch::Plugin
  include CustomHelpers

  set :help, <<-HELP
swanson
  This will return a random Ron Swanson quote.
  HELP

  match /swanson\b(?: (.+))?/i, method: :cswanson

  def cswanson(m)
    if !is_blacklisted?(m.channel, m.user.nick)
      uri = URI.parse("https://ron-swanson-quotes.herokuapp.com/v2/quotes")
      Net::HTTP.start(uri.host, uri.port, use_ssl: true) do |http|
        resp = Net::HTTP.get_response(uri)
        begin
          data = JSON.parse(resp.body)
          if !data.nil?
            m.reply "\"#{data[0]}\" - Ron Swanson"
          else
            m.reply "I've run into an unexpected error."
          end
        rescue JSON::ParserError
          m.reply "Sorry, the API returned an invalid/missing JSON."
        end
      end
    else
      m.user.send BLMSG
    end

  end

end