require 'net/http'
require 'json'
require_relative 'shorten'

class Wtfnews
  include Cinch::Plugin
  include CustomHelpers

  set :help, <<-HELP
news <optnum>
  Returns the "today in one sentence" for the given <optnum> (today is 0 and default, yesterday is 1...) from WTFJustHappenedToday.
  HELP

  match /news\b(?: (.+))?/i, method: :cnews

  def cnews(m, num)
    if !is_blacklisted?(m.channel, m.user.nick)
      num = 0 unless !num.nil?
      m.reply getheadline(num.to_i), true
    else
      m.user.send BLMSG
    end
  end

  private

  def getheadline(num)
    uri = URI.parse('https://whatthefuckjusthappenedtoday.com/api/v1/posts.json')
    data = JSON.parse(Net::HTTP.get_response(uri).body)

    return data['allPosts'][num]['todayInOneSentence'] + " - " + Shorten.shorten(data['allPosts'][num]['href'])

  end

end