require 'net/http'
require 'json'

class Tungsten
  include Cinch::Plugin
  include CustomHelpers

  set :help, <<-HELP
tungsten 
  This will return the ranking of tungsten renders by user.
  HELP

  match /tungsten(?: (.+))?/i

  def execute(m, text)
    if !is_blacklisted?(m.channel, m.user.nick)

      counts = Hash.new(0)

      uri = URI.parse("https://benedikt-bitterli.me/renderfarm/scenes/instancing/frames")
      Net::HTTP.start(uri.host, uri.port) do |h|
        resp = Net::HTTP.get_response(uri)
        begin
          data = JSON.parse(resp.body)
          names = data.map { |p| p['owner'] }
          names.reject { |k| k == ""}.each { |n| counts[n] +=1 }
          total = names.size
          empty = names.select {|k| k == ""}.size
          list = counts.sort_by {|k,v| v}.reverse.map.with_index(1) {|k,v| ["\##{v}| #{k[0]}(#{(k[1].to_f / total *100).round(2)}%/#{k[1]})"]}.join(", ")

          m.reply "Current Results: (#{((total-empty).to_f / total * 100).round(2)}% complete (#{total-empty}/#{total})) #{list}"
        rescue JSON::ParserError

          m.reply "I'm unable to parse that boss.", true
        end

      end
    else
      m.user.send BLMSG
    end
  end

end
