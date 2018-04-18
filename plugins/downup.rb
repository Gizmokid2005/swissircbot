require 'mechanize'

class Downup
  include Cinch::Plugin
  include CustomHelpers

  set :help, <<-HELP
down/up <url>
  This will check if url is up.
  HELP

  match /(?:down|up) (.+)/i

  def execute(m,url)
    if !is_blacklisted?(m.channel, m.user.nick)
      m.reply "Looks like #{url} is #{check(url)}.", true
    else
      m.user.send BLMSG
    end
  end

  def check(url)

    uri = URI.parse("http://downforeveryoneorjustme.com/#{url}")
    agent = Mechanize.new
    agent.user_agent_alias = 'Linux Firefox'
    page = agent.get(uri)
    resp = page.content.match("It's just you")

    if resp.to_s.nil?
      return "down"
    else
      return "up"
    end

  end

end