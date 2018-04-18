require 'open-uri'
require 'mechanize'

class Urlinfo
  include Cinch::Plugin
  include CustomHelpers

  set :help, <<-HELP
title <fullurl>
  This attempts to retun the title of fullurl.
  HELP

  #match %r{(?i)\b((?:[a-z][\w-]+:(?:/{1,3}|[a-z0-9%])|www\d{0,3}[.]|[a-z0-9.\-]+[.][a-z]{2,4}/)(?:[^\s()<>]+|\(([^\s()<>]+|(\([^\s()<>]+\)))*\))+(?:\(([^\s()<>]+|(\([^\s()<>]+\)))*\)|[^\s`!()\[\]{};:'".,<>?«»“”‘’]))}, :use_prefix => false
  match /title (.+)/i

  def execute(m, url)
    if !is_blacklisted?(m.channel, m.user.nick)

      #return if m.message.to_s.start_with?(PREFIX)

      agent = Mechanize.new
      agent.user_agent_alias = 'Linux Firefox'

      if title = agent.get(url).title.gsub(/(\r)?(\n)+/, ' ').lstrip.first(200)
        m.reply "Title: #{title}"
      else
        #m.reply "I don't know what to do with this.", true #Do we really need a reply?
      end

    else
      m.user.send BLMSG
    end
  end

end