require 'open-uri'
require 'mechanize'

class UrlInfo
  include Cinch::Plugin

  match %r{(?i)\b((?:[a-z][\w-]+:(?:/{1,3}|[a-z0-9%])|www\d{0,3}[.]|[a-z0-9.\-]+[.][a-z]{2,4}/)(?:[^\s()<>]+|\(([^\s()<>]+|(\([^\s()<>]+\)))*\))+(?:\(([^\s()<>]+|(\([^\s()<>]+\)))*\)|[^\s`!()\[\]{};:'".,<>?«»“”‘’]))}, :use_prefix => false

  def execute(m, url)
    # Blacklist support??

    agent = Mechanize.new
    agent.user_agent_alias = 'Mac Safari'

    if title = agent.get(url).title

      m.reply "#{m.user.nick}: #{title} - #{url}"

    else

      m.reply "#{m.user.nick}: I don't know what to do with this."

    end

  end

end