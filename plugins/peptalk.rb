class Peptalk
  include Cinch::Plugin
  include CustomHelpers

  set :help, <<-HELP
peptalk/pep
  This will give you a quick pep talk!
  HELP

  match /(peptalk|pep)\b/i, method: :cpeptalk

  def cpeptalk (m)
    if !is_blacklisted?(m.channel, m.user.nick)

      part1 = ["Champ,", "Fact:", "Everybody says", "Check it:", "Just saying...", "Superstar,", "Tiger,", "Self,",
               "Know this:", "News alert:", "Girl,", "Ace,", "Excuse me but", "Experts agree:", "In my opinion,", "Hear ye, hear ye:",
               "Okay, listen up:"]
      part2 = ["the mere idea of you", "your soul", "your hair today", "everything you do", "your personal style", "every thought you have",
               "that sparkle in your eye", "your presence here", "what you got going on", "the essential you", "your life's journey",
               "that saucy personality", "your DNA", "that brain of yours", "your choice of attire", "the way you roll", 
               "whatever your secret is", "all of y'all"]
      part3 = ["has serious game,", "rains magic,", "deserve the Nobel Prize,", "raises the roof,", "breeds miracles,",
               "is paying off big time,", "shows mad skills,", "just shimmers,", "is a national treasure,", "gets the party hopping,",
               "is the next big thing,", "roars like a lion,", "is a rainbow factory,", "is made of diamonds,", "makes birds sing,",
               "should be taught in school,", "makes my world go 'round,", "is 100% legit,"]
      part4 = ['24/7.', 'can I get an amen?', "and that's a fact.", "so treat yourself.", "you feel me?", "that's just science.",
               "would I lie?", "for reals.", "mic drop.", "you hidden gem.", "snuggle bear.", "period.", "can I get an FSM?",
               "now let's dance", "high five!", "say it again!", "according to CNN.", "so get used to it."]

      newpeptalk = @lastpeptalk

      while @lastpeptalk == newpeptalk || newpeptalk.empty?
        newpeptalk = [part1.sample, part2.sample, part3.sample, part4.sample].join(' ')
      end
      @lastpeptalk = newpeptalk
      print @lastpeptalk

      m.reply @lastpeptalk, true
    else
      m.user.send BLMSG
    end

  end

end