require 'chronic'
class Memos
  include Cinch::Plugin
  include CustomHelpers

  set :help, <<-HELP
tell/ask <user> <message>
  This will send user the message the next time they speak.
remind <user> [in <timespec>] <message>
  This will send <user> the <message> after the requested <timespec> has passed and they speak again (5 minute default if not provided)
remind <user> <message> [in <timespec>]
  This will send <user> the <message> after the requested <timespec> has passed and they speak again (5 minute default if not provided)
  HELP

  listen_to :message

  match /(tell|ask) (.+?) (.+)/i, method: :memo
  match /remind(.+)/i, method: :remind


  def remind(m, blob)
    if !is_blacklisted?(m.channel, m.user.nick)

      @who = nil
      @remindtime = nil
      @text = nil
      matchpats = [
                    '(?<user>\w+) (?<timespec>in (\d+ \w+?s? ?)+) (?<action>.*?)$',
                    '(?<user>\w+) (?<action>.*?) (?<timespec>in (\d+ \w+?s? ?)+)$',
                    '(?<user>\w+) (?<action>.+)'
                  ]

      matchpats.each do |regex|
        sm = blob.match /#{regex}/i
        if !sm.nil? && !(@who.present? && @remindtime.present? && @text.present?)
          @who = (sm['user'] == 'me') ? m.user.nick : sm['user']
          @remindtime = (sm.names.include? 'timespec') ? Chronic.parse(sm['timespec']) : (Time.now + 5*60)
          @text = sm['action']
        end
      end
      if @who == m.bot.nick
        m.reply "I'm not interested.", true
      else
        location = if m.channel then m.channel.to_s else 'private ' end
        save_memov2(@who, m.user.nick, location, @text, Time.now, @remindtime)
        m.reply "Reminder for #{@who} saved", true
      end

    else
      m.user.send BLMSG
    end
  end

  def memo(m, mtype, who, text)
    if !is_blacklisted?(m.channel, m.user.nick)
      if who == m.user.nick
        m.reply "tell that to yourself...", true
      elsif who == m.bot.nick
        m.reply "I'm not interested.", true
      else
        location = if m.channel then m.channel.to_s else 'private ' end
        save_memo(who, m.user.nick, location, mtype, text, DateTime.now)
        m.reply "I'll let #{who} know when I see them.", true
      end
    else
      m.user.send BLMSG
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

    memosv2 = get_memosv2(m.user.nick)
    if memosv2.any?
      memosv2.each do |mem|
        remindtime = Time.parse(mem[4])
        now = Time.new
        totaltime = (now - remindtime).to_i
        seconds = totaltime % 60
        minutes = (totaltime / 60 ) % 60
        hours = (totaltime / 60 / 60) % 24
        days = (totaltime / 60 / 60 / 24) % 7
        weeks = (totaltime / 60 / 60 / 24 / 7) % 30

        # m.user.notice "#{mem[1]} reminds you \"#{mem[3]}\" #{weeks}w #{days}d #{hours}h #{minutes}m #{seconds}s ago"
        m.reply "#{mem[1]} reminds you \"#{mem[3]}\" (#{weeks}w #{days}d #{hours}h #{minutes}m #{seconds}s ago)", true
      end
    end
  end

end