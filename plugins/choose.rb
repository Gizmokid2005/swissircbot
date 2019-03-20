class Choose
  include Cinch::Plugin
  include CustomHelpers

  set :help, <<-HELP
choose <list,of,options>
  Picks an item from the comma-separated list of options provided.
  HELP

  match /choose (.+)/i, method: :choose

  def choose(m,list)
    if !is_blacklisted?(m.channel, m.user.nick)
      list = list.split(',')
      m.reply list.sample, true
    else
      m.user.send BLMSG
    end
  end

end