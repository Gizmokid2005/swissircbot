class Define
  include Cinch::Plugin
  include CustomHelpers

  set :help, <<-HELP
define/def <word> <definition>
  This will set the definition of word.
forget <word>
  This will remove the definition of word.
forgetme
  This will remove the definition for your current nick.
defsource <word>
  This will return who set the definition for word.
  HELP

  match /(?:define|def)$/i, method: :cblankdef
  match /(?:define|def) (\S+)(?: (.+))?/i, method: :cdef
  match /forget (.+)/i, method: :cforget
  match /forgetme$/i, method: :cforgetme
  match /defsource (.+)/i, method: :cblame

  def cblankdef(m)
    if !is_blacklisted?(m.channel, m.user.nick)
      dm = get_definition(m.user.nick)
      if dm.present?
        m.reply dm, true
      else
        m.reply "I don't know about you!", true
      end
    else
      m.user.send BLMSG
    end
  end

  def cdef(m, term, meaning)
    if !is_blacklisted?(m.channel, m.user.nick)
      term = m.user.nick unless term.present?
      if meaning.present?
        if save_definition(m.user.nick, term, meaning)
          m.reply "I've saved that for you boss", true
        else
          m.reply "Something went wrong, sorry.", true
        end
      else
        dm = get_definition(term)
        if dm.present?
          m.reply "#{term} #{dm}"
        else
          m.reply "I don't know about #{term}", true
        end
      end
    else
      m.user.send BLMSG
    end
  end

  def cforget(m, term)
    if !is_blacklisted?(m.channel, m.user.nick)
      dm = del_definition(term)
      if dm.present?
        m.reply "Huh? I forgot what #{term} was..", true
      else
        m.reply "I can't forget that.", true
      end
    else
      m.user.send BLMSG
    end
  end

  def cforgetme(m)
    if !is_blacklisted?(m.channel, m.user.nick)
      dm = del_definition(m.user.nick)
      if dm.present?
        m.reply "Who is #{m.user.nick}?"
      else
        m.reply "Something is horribly wrong.", true
      end
    else
      m.user.send BLMSG
    end
  end

  def cblame(m, term)
    if !is_blacklisted?(m.channel, m.user.nick)
      who = definition_source(term)
      if who
        m.reply "#{term} was defined by #{who}.", true
      else
        m.reply "I don't know about #{term}", true
      end
    else
      m.user.send BLMSG
    end
  end

end