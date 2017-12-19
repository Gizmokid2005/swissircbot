class Dice
  include Cinch::Plugin

  set :help, <<-HELP
dice/roll <numberofdice>d<sides> [2d6 for 2 d6]
  Rolls the number of size dice. Assumes 1 if no quantity is given.
  HELP

  match /(?:dice|roll) (\d+)?[d](\d+)/i, method: :roll

  def roll(m,dice,sides)
    dice = 1 unless !dice.nil? || !dice.empty?
    total = 0

    dice.to_i.times do
      total += rand(sides.to_i) + 1
    end

    m.reply "Your roll was #{total}", true
  end

end