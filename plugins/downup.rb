require 'mechanize'

class DownUp
  include Cinch::Plugin

  match /(?:down|up) (.+)/

  def execute(m,url)
    m.reply "#{m.user.nick}: Looks like #{url} is #{check(url)}."
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