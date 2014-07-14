require 'open-uri'
require 'mechanize'

class UrlInfo
  include Cinch::Plugin

  match %r{(?i)\b((?:[a-z][\w-]+:(?:/{1,3}|[a-z0-9%])|www\d{0,3}[.]|[a-z0-9.\-]+[.][a-z]{2,4}/)(?:[^\s()<>]+|\(([^\s()<>]+|(\([^\s()<>]+\)))*\))+(?:\(([^\s()<>]+|(\([^\s()<>]+\)))*\)|[^\s`!()\[\]{};:'".,<>?«»“”‘’]))}, :use_prefix => false

  def execute(m, url)
    # Blacklist support??

    return if m.message.to_s.start_with?(PREFIX)

    agent = Mechanize.new
    agent.user_agent_alias = 'Linux Firefox'

    if title = agent.get(url).title.gsub(/(\r)?(\n)+/, ' ').lstrip

      m.reply "Title: #{title} - #{url} - posted by \"#{m.user.nick}\""

    else

      m.reply "I don't know what to do with this.", true

    end

  end

end