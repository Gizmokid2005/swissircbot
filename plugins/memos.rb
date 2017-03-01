class Memos
  include Cinch::Plugin

  set :help, <<-HELP
tell/ask <user> <message>
  This will send user the message the next time they speak.
  HELP

  listen_to :message

  match /(tell|ask) (.+?) (.+)/i, method: :memo

  def memo(m, mtype, who, text)
    if who == m.user.nick
      m.reply "tell that to yourself...", true
    elsif who == m.bot.nick
      m.reply "I'm not interested.", true
    elsif
      location = if m.channel then m.channel.to_s else 'private ' end
      save_memo(who, m.user.nick, location, mtype, text, DateTime.now)
      if mtype == "tell"
        m.reply "I'll let #{who} know when I see them.", true
      elsif mtype == "ask"
        m.reply "I'll ask #{who} that when I see them.", true
      else
        m.reply "I'll pass that along to #{who} when I see them.", true
      end
    end
  end

  def listen(m)
    memos = get_memos(m.user.nick)
    if memos.any?
      memos.each do |mem|
        if mem[3] == "ask"
          memtype = "asked"
        else
          memtype = "told"
        end
        m.reply "#{mem[1]} #{memtype} you \"#{mem[4]}\" on #{mem[5]}", true
      end
    end
  end

end