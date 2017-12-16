require 'net/http'
require 'json'

class Shorten
  include Cinch::Plugin

  set :help, <<-HELP
shorten <url>
  This will return a short url for the given url.
  HELP

  match /shorten (.+)/

  def execute(m, url)
    m.reply shorten(url), true
  end

  private
  def shorten(url)

    uri = URI.parse("https://www.googleapis.com/urlshortener/v1/url?key=#{GOOGLEAPIKEY}")
    data = {longUrl: "#{url}"}
    res = Net::HTTP.start(uri.host, uri.port, use_ssl: true) do |http|
      req = Net::HTTP::Post.new(uri)
      req['Content-Type'] = 'application/json'
      req.body = data.to_json
      http.request(req)
    end

    short = JSON.parse(res.body)
    return short['id']

  end

end