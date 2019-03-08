require 'net/http'
require 'json'

class Tungsten
  include Cinch::Plugin
  include CustomHelpers

  set :help, <<-HELP
tungsten 
  This will return the ranking of tungsten renders by user.
  HELP

  match /rf(?: (.+))?/i

  def execute(m, text)
    if !is_blacklisted?(m.channel, m.user.nick)
      if text.nil?
        uri = URI.parse("https://benedikt-bitterli.me/renderfarm/scenes")
        Net::HTTP.start(uri.host, uri.port) do |h|
          resp = Net::HTTP.get_response(uri)
          begin
            data = JSON.parse(resp.body)
            list = data.join(", ")

            m.reply "You need to pick one of these scenes boss: #{list}.", true
          rescue JSON::ParserError

            m.reply "I'm unable to parse that boss.", true
          end
        end
      else
        counts = Hash.new(0)

        uri = URI.parse("https://benedikt-bitterli.me/renderfarm/scenes/#{text}/frames")
        Net::HTTP.start(uri.host, uri.port) do |h|
          resp = Net::HTTP.get_response(uri)
          begin
            data = JSON.parse(resp.body)
            complete = data.select { |p| p['state'] == "complete"}.size
            data.select { |p| p['state'] == "complete"}.map { |p| p['owner'] }.each { |n| counts[n] +=1 }
            total = data.size
            list = counts.sort_by {|k,v| v}.reverse.map.with_index(1) {|k,v| ["\##{v}|#{k[0].slice(0..2)}(#{(k[1].to_f / total *100).round(2)}%/#{k[1]})"]}.join(", ")

            m.reply "Current Results: (#{(complete.to_f / total * 100).round(2)}% complete (#{complete}/#{total})) #{list}"
          rescue JSON::ParserError

            m.reply "I'm unable to parse that boss.", true
          end

        end
      end
    else
      m.user.send BLMSG
    end
  end

end
