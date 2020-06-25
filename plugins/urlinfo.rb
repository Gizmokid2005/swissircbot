require 'open-uri'
require 'nokogiri'
require 'cgi'

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

      @res = Nokogiri.parse(open(url.to_s).read).at("title")

      if (title = @res.text.gsub(/(\r)?(\n)+/, ' ').lstrip.first(200))
        m.reply "Title: #{title}"
      end

    else
      m.user.send BLMSG
    end
  end

end