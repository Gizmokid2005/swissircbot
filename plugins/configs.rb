class Configs
  include Cinch::Plugin
  include CustomHelpers

  set :help, <<-HELP
config set <plugin> <option> <value>
  This will set a default <value> for the given <option> for a given <plugin> - eg. '.config set weather location 90210' will set your default weather location to 90210.
config clear <plugin> <option>
  This will clear the <option> for the given <plugin> - eg. '.config clear weather location' will remove any saved location for the weather plugin.
  HELP

  match /config set\b ?(\w+) (\w+) (.+)$/i, method: :csetconfig
  match /config clear\b ?(\w+) (\w+)/i, method: :cclearconfig

  def csetconfig(m, plugin, ckey, cvalue)
    if !is_blacklisted?(m.channel, m.user.nick)

      # Do we already have this config saved?
      if db_config_get(m.user.authname.presence || m.user.nick, plugin, ckey).present?
        m.reply "You have already set #{ckey} for #{plugin}.", true
      else

        # Save the config
        cfg = db_config_save(m.user.authname.presence || m.user.nick, plugin, ckey, cvalue)
        if cfg.present?
          m.reply "I have saved your #{ckey} value for the #{plugin} plugin.", true
        else
          # If we can't, grotesquely fail
          m.reply "Sorry, I was unable to save this config. Poke #{$superadmins}.", true
        end
      end
    else
      m.user.send BLMSG
    end
  end

  def cclearconfig(m, plugin, ckey)
    if !is_blacklisted?(m.channel, m.user.nick)

      # Do we already have this config saved?
      if db_config_get(m.user.authname.presence || m.user.nick, plugin, ckey).present?
        if db_config_clear(m.user.authname.presence || m.user.nick, plugin, ckey)
          m.reply "I have removed your #{ckey} value for the #{plugin} plugin.", true
        end
      else
        m.reply "Sorry, I don't seem to have this config set for you.", true
      end
    else
      m.user.send BLMSG
    end
  end

end