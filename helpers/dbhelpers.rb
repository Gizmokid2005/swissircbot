require 'sqlite3'

module DBHelpers

  def open_create_db
    db_file = File.join($confdir, "#{SERVER}_#{NICK}_db.sqlite3")

    if File.exist?(db_file)
      db = SQLite3::Database.open(db_file)
    else
      db = SQLite3::Database.new(db_file)
    end

    if db
      db.execute("CREATE TABLE IF NOT EXISTS memos(id INTEGER PRIMARY KEY, nick VARCHAR(50), origin VARCHAR(50)
                  , location VARCHAR(10), mtype VARCHAR(5), message TEXT, time VARCHAR(50));")
      db.execute("CREATE TABLE IF NOT EXISTS seen(id INTEGER PRIMARY KEY, nick VARCHAR(50), location VARCHAR(10), time VARCHAR(50));")
      db.execute("CREATE TABLE IF NOT EXISTS quotes(id INTEGER PRIMARY KEY, quote VARCHAR(800), user VARCHAR(50), time VARCHAR(50)
                  , lastused VARCHAR(50));")
      db.execute("CREATE TABLE IF NOT EXISTS packages(id INTEGER PRIMARY KEY, trk_id VARCHAR(150), tracknum VARCHAR(100)
                  , courier VARCHAR(20), name VARCHAR(200), nick VARCHAR(50), updated_at VARCHAR(50), status VARCHAR(200), location VARCHAR(150)
                  , delivered INTEGER, deleted INTEGER);")
      db.execute("CREATE TABLE IF NOT EXISTS tunaimgur(id INTEGER PRIMARY KEY, url VARCHAR(150), time VARCHAR(50), lastused VARCHAR(50));")
      db.execute("CREATE TABLE IF NOT EXISTS userconfigs(id INTEGER PRIMARY KEY, nick VARCHAR(50), plugin VARCHAR(50), configkey VARCHAR(100), configvalue VARCHAR(100));")
      db.execute("CREATE TABLE IF NOT EXISTS memosv2(id INTEGER PRIMARY KEY, nick VARCHAR(50), origin VARCHAR(50)
                  , location VARCHAR(10), message TEXT, savetime VARCHAR(50), remindtime VARCHAR(50));")
    end
    return db
  end

  # Start Memos
  def save_memov2(nick, origin, location, message, savetime, remindtime)
    db = open_create_db
    if db
      db.execute("INSERT INTO memosv2(nick, origin, location, message, savetime, remindtime) VALUES(?,?,?,?,?,?)", nick.downcase, origin, location, message, savetime.to_s, remindtime.to_s)
    end
  end

  def get_memosv2(nick)
    db = open_create_db
    if db
      curtime = Time.now.to_s
      result = db.execute("SELECT nick, origin, location, message, savetime, remindtime FROM memosv2 WHERE nick = ? AND remindtime <= ?", nick.downcase, curtime)
      db.execute("DELETE FROM memosv2 WHERE nick = ? AND remindtime <= ?", nick.downcase, curtime)
    end
    db.close
    return result
  end
  def save_memo(nick, origin, location, mtype, message, time)
    db = open_create_db
    if db
      db.execute("INSERT INTO memos(nick, origin, location, mtype, message, time) VALUES(?,?,?,?,?,?);", nick.downcase, origin, location, mtype, message, time.strftime("%b %d, %Y at %l:%M:%S %p (%Z)").to_s)
    end
    db.close
  end

  def get_memos(nick)
    db = open_create_db
    if db
      result = db.execute("SELECT nick, origin, location, mtype, message, time FROM memos WHERE nick = ?", nick.downcase)
      db.execute("DELETE FROM memos WHERE nick = ?", nick.downcase)
    end
    db.close
    return result
  end

  def i_see(nick, location, time)
    db = open_create_db
    if db
      db.execute("INSERT OR REPLACE INTO seen(id, nick, location, time) VALUES((SELECT id FROM seen WHERE nick = ?),?,?,?);", nick.downcase, nick.downcase, location, time.strftime("%b %d, %Y at %l:%M:%S %p (%Z)").to_s)
    end
    db.close
  end

  def seen_who(nick)
    db = open_create_db
    if db
      result = db.execute("SELECT location, time FROM seen WHERE nick = ?", nick.downcase)
    end
    db.close
    return result
  end
  # End Memos

  # Start Quotes
  def add_quote(nick, quote, time)
    db = open_create_db
    if db
      db.execute("INSERT INTO quotes(quote, user, time) VALUES(?,?,?);", quote, nick, time.strftime("%b %d, %Y at %l:%M:%S %p (%Z)").to_s)
    end
    result = db.last_insert_row_id
    db.close
    return result
  end

  def del_quote(qid)
    db = open_create_db
    if db
      db.execute("DELETE FROM quotes WHERE id = ?", qid)
      result = db.changes
    end
    db.close
    return result
  end

  def get_quote(qid)
    db = open_create_db
    if db
      result = db.execute("SELECT quote FROM quotes WHERE id = ?", qid)
    end
    db.close
    return result
  end

  def rand_quote()
    db = open_create_db
    if db
      quotecount = db.execute("SELECT COUNT(*) FROM quotes")[0]
      offset = Math.sqrt(rand(0.0...(quotecount[0] * quotecount[0]))).floor
      result = db.execute("SELECT id, quote FROM quotes ORDER BY lastused DESC LIMIT 1 OFFSET ?;", offset)
      db.execute("UPDATE quotes SET lastused = ? WHERE id = ?", DateTime.now.strftime("%b %d, %Y at %l:%M:%S %p (%Z)").to_s, result[0][0])
    end
    db.close
    return result
  end

  def find_quote(text)
    db = open_create_db

    if db
      quotecount = db.execute("SELECT COUNT(*) FROM quotes WHERE quote LIKE ? ORDER BY RANDOM() LIMIT 1;", "%#{text}%")
      if quotecount[0][0] > 1
        result = @lastquote
        while @lastquote == result || result.empty?
          result = db.execute("SELECT id, quote FROM quotes WHERE quote LIKE ? ORDER BY RANDOM() LIMIT 1;", "%#{text}%")
        end
        @lastquote = result
      else
        result = db.execute("SELECT id, quote FROM quotes WHERE quote LIKE ? ORDER BY RANDOM() LIMIT 1;", "%#{text}%")
      end
    end
    db.close
    return result
  end

  def quote_info(qid)
    db = open_create_db

    if db
      result = db.execute("SELECT id, quote, user, time FROM quotes WHERE id = ?", qid)
    end
    db.close
    return result
  end
  # End Quotes

  # Start PackageTracking
  def db_save_new_package(nick, trk_id, tracknum, courier, name, status, location, updated_at, delivered)
    db = open_create_db

    if db
      db.execute("INSERT INTO packages(nick, trk_id, tracknum, courier, name, status, location, delivered, updated_at) VALUES(?,?,?,?,?,?,?,?,?)", nick.downcase, trk_id, tracknum.upcase, courier, name, status, location, delivered, updated_at.to_s)
      result = db.changes
    end
    db.close
    return result
  end

  def db_update_package_status(nick, trk_id, tracknum, status, location, updated_at, delivered)
    db = open_create_db

    if db
      db.execute("UPDATE packages SET status = ?, location = ?, delivered = ?, updated_at = ? WHERE tracknum = ? AND nick = ? AND trk_id = ?", status, location, delivered, updated_at.to_s, tracknum.upcase, nick.downcase, trk_id)
      result = db.execute("SELECT name FROM packages WHERE tracknum = ? AND nick = ? AND trk_id = ?", tracknum.upcase, nick.downcase, trk_id)
      # result = db.changes
    end
    db.close
    return result
  end

  def db_push_update_package(trk_id, tracknum, status, location, updated_at, delivered)
    db = open_create_db

    if db
      db.execute("UPDATE packages SET status = ?, location = ?, delivered = ?, updated_at = ? WHERE tracknum = ? AND trk_id = ? AND COALESCE(deleted,0) = 0", status, location, delivered, updated_at.to_s, tracknum.upcase, trk_id)
      result = db.execute("SELECT nick FROM packages WHERE tracknum = ? AND trk_id = ? AND COALESCE(deleted,0) = 0", tracknum.upcase, trk_id)
      # result = db.changes
    end
    db.close
    return result
  end

  def db_get_all_packages(nick)
    db = open_create_db

    pp "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
    pp "I'm in db_get_all_packages and I'm looking for packages for #{nick.downcase}"
    pp "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"

    if db
      result = db.execute("SELECT trk_id, tracknum, name, courier, nick, updated_at, status, location FROM packages WHERE nick = ? AND COALESCE(delivered,0) = 0 AND COALESCE(deleted,0) = 0;", nick.downcase)

      pp "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
      pp "I'm in db_get_all_packages and my result is:"
      pp result
      pp "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"

    end
    db.close
    return result
  end

  def db_package_by_id(trk_id)
    db = open_create_db

    if db
      result = db.execute("SELECT trk_id, tracknum, name, courier, nick, updated_at, status, location FROM packages WHERE trk_id = ? AND delivered = 0 AND COALESCE(deleted,0) = 0;", trk_id)
    end
    db.close
    return result
  end

  def db_find_package(nick, tracknum)
    db = open_create_db

    if db
      result = db.execute("SELECT nick, tracknum FROM packages WHERE nick = ? AND tracknum = ? AND COALESCE(deleted,0) = 0", nick.downcase, tracknum.upcase)
    end
    db.close
    return result
  end

  def db_remove_package(nick, tracknum)
    db = open_create_db

    if db
      db.execute("UPDATE packages SET deleted = 1 WHERE nick = ? AND tracknum = ?", nick.downcase, tracknum.upcase)
      result = db.changes
    end
    db.close
    return result
  end
  # End PackageTracking


  # Start TunaImgur
  def db_tuna_add(url)
    db = open_create_db

    if db
      db.execute("INSERT INTO tunaimgur(url, time) VALUES(?,?)", url, DateTime.now.strftime("%b %d, %Y at %l:%M:%S %p (%Z)").to_s )
    end
    result = db.execute("SELECT 1 FROM tunaimgur WHERE url = ?", url)
    return result[0][0]
    db.close
  end

  def db_tuna_geturl()
    db = open_create_db

    if db
      urlcount = db.execute("SELECT COUNT(*) FROM tunaimgur")[0]
      offset = Math.sqrt(rand(0.0...(urlcount[0] * urlcount[0]))).floor
      result = db.execute("SELECT id, url FROM tunaimgur ORDER BY lastused DESC LIMIT 1 OFFSET ?;", offset)
      db.execute("UPDATE tunaimgur SET lastused = ? WHERE id = ?", DateTime.now.strftime("%b %d, %Y at %l:%M:%S %p (%Z)").to_s, result[0][0])
    end
    db.close
    return result
  end

  def db_tuna_check(url)
    db = open_create_db

    if db
      result = db.execute("SELECT 1 FROM tunaimgur WHERE url = ?", url)
    end
    db.close
    return result
  end
  # End TunaImgur

  # Start CustomQuery
  def db_custom_query(query)
    db = open_create_db

    if db
      result = db.execute(query)
    end
    db.close
    return result
  end
  # End CustomQuery

  # Start ConfigValues
  def db_config_save(nick, plugin, configkey, configvalue)
    db = open_create_db

    if db
      db.execute("INSERT INTO userconfigs(nick, plugin, configkey, configvalue) VALUES(?,?,?,?);", nick.downcase, plugin, configkey, configvalue)
    end
    result = db.last_insert_row_id
    db.close
    return result
  end


  def db_config_get(nick, plugin, configkey)
    db = open_create_db

    if db
      result = db.execute("SELECT * FROM userconfigs WHERE nick = ? AND plugin = ? AND configkey = ?", nick.downcase, plugin, configkey)
    end
    db.close
    return result
  end

  def db_config_clear(nick, plugin, configkey)
    db = open_create_db

    if db
      db.execute("DELETE FROM userconfigs WHERE nick = ? AND plugin = ? AND configkey = ?;", nick.downcase, plugin, configkey)
      result = db.changes
    end
    db.close
    return result
  end
  # End ConfigValues
end
