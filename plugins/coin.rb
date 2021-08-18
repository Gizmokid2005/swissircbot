class Coin
  include Cinch::Plugin
  include CustomHelpers

  set :help, <<-HELP
coin/flip <optnumberofcoins>
  Rolls the number of size dice. Assumes 1 if no quantity is given.
  HELP

  match /(?:coin|flip)\b(?: (.+))?/i, method: :flip

  def flip(m,coins)
    if !is_blacklisted?(m.channel, m.user.nick)
      coins = 1 unless !coins.nil?
      flips = []

      coins.to_i.times do
        flips.append %w[heads tails].sample
      end

      if coins == 1
        m.reply flips[0], true
      else
        m.reply "#{flips.count('heads')} heads, #{flips.count('tails')} tails", true
      end

    else
      m.user.send BLMSG
    end
  end

end