class Dice
  include Cinch::Plugin
  include CustomHelpers

  set :help, <<-HELP
dice/roll <numberofdice>d<sides> [2d6 for 2 d6]
  Rolls the number of size dice. Assumes 1 if no quantity is given.
  HELP

  match /(?:dice|roll)(?=\s|$)(?: (\d+)?d(\d+))?/i, method: :roll

  def roll(m,dice,sides)
    pp "My objects are dice:|#{dice}| and sides:|#{sides}|"
    if !is_blacklisted?(m.channel, m.user.nick)
      if sides.nil?
        m.reply "Sorry, please specify the number of sides at least (e.g. d6).", true
      else
        dice = 1 unless !dice.nil?
        total = 0

        dice.to_i.times do
          total += rand(sides.to_i) + 1
        end

        m.reply total, true
      end

    else
      m.user.send BLMSG
    end
  end

end