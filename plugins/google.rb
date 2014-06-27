class Google
  include Cinch::Plugin

  match /google (.+)/i

  def search(query)
    url = "http://www.google.com/search?q=#{CGI.escape(query)}"
    res = Nokogiri.parse(open(url.to_s).read).at("h3.r")

    title = res.text
    link = res.at('a')[:href].gsub("/url?q=","")
    desc = res.at("./following::div").children.first.text
    CGI.unescape_html "#{title} - #{desc} (#{link})"

  end

  def execute(m,query)
    m.reply "#{m.user.nick}: #{search(query)}"
  end

end