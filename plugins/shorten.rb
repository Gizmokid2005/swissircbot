require 'net/http'
require 'json'

class Shorten
  include Cinch::Plugin

  match /shorten (.+)/

  def execute(m,url)
    m.reply "#{m.user.nick}: #{shorten(url)}"
  end

  private
  def shorten(url)

    uri = URI.parse("https://www.googleapis.com/urlshortener/v1/url?key=#{GOOGLEAPIKEY}")
    data = {longUrl: "#{url}"}
    req = Net::HTTP::Post.new(uri.path)
    req.body = data.to_json
    req['Content-Type'] = 'application/json'
    res = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
      http.request(req)
    end

    short = JSON.parse(res.body)
    return short['id']

  end

end