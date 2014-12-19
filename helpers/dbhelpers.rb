module DBHelpers

  def open_create_db
    db_file = File.join($confdir, "swissircbot.sqlite3")

    if File.exists?(db_file)
      db = SQLite3::Database.open(db_file)
    else
      db = SQLite3::Database.new(db_file)
    end

    if db
      db.execute("CREATE TABLE IF NOT EXISTS memos(id INTEGER PRIMARY KEY, nick VARCHAR(50), origin VARCHAR(50)
                  , location VARCHAR(10), mtype VARCHAR(5), message TEXT, time VARCHAR(50));")
      db.execute("CREATE TABLE IF NOT EXISTS seen(id INTEGER PRIMARY KEY, nick VARCHAR(50), location VARCHAR(10), time VARCHAR(50));")
    end
    return db
  end

  def save_memo(nick, origin, location, mtype, message, time)
    db = open_create_db
    if db
      db.execute("INSERT INTO memos(nick, origin, location, mtype, message, time) VALUES(?,?,?,?,?,?);", nick, origin, location, mtype, message, time.strftime("%b %d, %Y at %l:%M:%S %p (%Z)").to_s)
    end
    db.close
  end

  def get_memos(nick)
    db = open_create_db
    if db
      result = db.execute("SELECT nick, origin, location, mtype, message, time FROM memos WHERE nick = ?", nick)
      db.execute("DELETE FROM memos WHERE nick = ?", nick)
    end
    db.close
    return result
  end

  def i_see(nick, location, time)
    db = open_create_db
    if db
      db.execute("INSERT OR REPLACE INTO seen(id, nick, location, time) VALUES((SELECT id FROM seen WHERE nick = ?),?,?,?);", nick, nick, location, time.strftime("%b %d, %Y at %l:%M:%S %p (%Z)").to_s)
    end
    db.close
  end

  def seen_who(nick)
    db = open_create_db
    if db
      result = db.execute("SELECT location, time FROM seen WHERE nick = ?", nick)
    end
    db.close
    return result
  end

end