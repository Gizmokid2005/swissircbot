require 'cgi'
require 'json'
require 'open-uri'

class UrbanDictionary
  include Cinch::Plugin

  match /(?:urban|ud) (.*)/

  def execute(m, query)
    m.reply "#{query} - #{search(query)}", true
  end

  private
  def search(query)
    uri = "http://api.urbandictionary.com/v0/define?term=%s" % [CGI.escape(query)]
    open(uri) do |f|
      obj = JSON.parse(f.read)
      if obj['list'].empty?
        "No result"
      else
        defn = obj['list'][0]['definition'].gsub(/(\r\n)+/, ' ')
        permlnk = obj['list'][0]['permalink']
        "#{defn} - #{permlnk}"
      end
    end
  rescue => e
    exception(e)
    "An exception occured"
  end
end