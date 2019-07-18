require 'sqlite3'

module DBHelpers

  def open_create_db
    db_file = File.join($confdir, "#{SERVER}_#{NICK}_db.sqlite3")

    if File.exists?(db_file)
      db = SQLite3::Database.open(db_file)
    else
      db = SQLite3::Database.new(db_file)
    end

    if db
      db.execute("CREATE TABLE IF NOT EXISTS memos(id INTEGER PRIMARY KEY, nick VARCHAR(50), origin VARCHAR(50)
                  , location VARCHAR(10), mtype VARCHAR(5), message TEXT, time VARCHAR(50));")
      db.execute("CREATE TABLE IF NOT EXISTS seen(id INTEGER PRIMARY KEY, nick VARCHAR(50), location VARCHAR(10), time VARCHAR(50));")
      db.execute("CREATE TABLE IF NOT EXISTS quotes(id INTEGER PRIMARY KEY, quote VARCHAR(800), user VARCHAR(50), time VARCHAR(50));")
      db.execute("CREATE TABLE IF NOT EXISTS packages(id INTEGER PRIMARY KEY, tracknum VARCHAR(100)
                  , courier VARCHAR(20), name VARCHAR(200), nick VARCHAR(50), updated_at VARCHAR(50), status VARCHAR(200), location VARCHAR(150)
                  , delivered INTEGER);")
    end
    return db
  end

  # Start Memos
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

  #Start Quotes
  def add_quote(nick, quote, time)
    db = open_create_db
    if db
      db.execute("INSERT INTO quotes(quote, user, time) VALUES(?,?,?);", quote, nick, time.strftime("%b %d, %Y at %l:%M:%S %p (%Z)").to_s)
    end
    result = db.execute("SELECT id FROM quotes WHERE time = ?", time.strftime("%b %d, %Y at %l:%M:%S %p (%Z)").to_s)
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
      result = db.execute("SELECT id, quote FROM quotes ORDER BY RANDOM() LIMIT 1;")
    end
    db.close
    return result
  end

  def find_quote(text)
    db = open_create_db

    if db
      result = db.execute("SELECT id, quote FROM quotes WHERE quote LIKE ? ORDER BY RANDOM() LIMIT 1;", "%#{text}%")
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
  #End Quotes

  #Start PackageTracking
  def db_save_new_package(nick, tracknum, courier, name, status, location, delivered)
    time = DateTime.now
    db = open_create_db

    if db
      db.execute("INSERT INTO packages(nick, tracknum, courier, name, status, location, delivered, updated_at) VALUES(?,?,?,?,?,?,?,?)", nick.downcase, tracknum.upcase, courier, name, status, location, delivered, time.strftime("%b %d, %Y at %l:%M:%S %p (%Z)").to_s)
      result = db.changes
    end
    db.close
    return result
  end

  def db_update_package_status(nick, tracknum, status, location, delivered)
    time = DateTime.now
    db = open_create_db

    if db
      db.execute("UPDATE packages SET status = ?, location = ?, delivered = ?, updated_at = ? WHERE tracknum = ? AND nick = ?", status, location, delivered, time.strftime("%b %d, %Y at %l:%M:%S %p (%Z)").to_s, tracknum.upcase, nick.downcase)
      result = db.execute("SELECT name FROM packages WHERE tracknum = ? and nick = ?", tracknum.upcase, nick.downcase)
      # result = db.changes
    end
    db.close
    return result
  end

  def db_get_all_packages(nick)
    db = open_create_db

    if db
      result = db.execute("SELECT tracknum, name, courier, nick, updated_at, status, location FROM packages WHERE nick = ? AND delivered = 0;", nick.downcase)
    end
    db.close
    return result
  end

  def db_find_package(nick, tracknum)
    db = open_create_db

    if db
      result = db.execute("SELECT * FROM packages WHERE nick = ? AND tracknum = ?", nick.downcase, tracknum.upcase)
    end
    db.close
    return result
  end

  def db_remove_package(nick, tracknum)
    db = open_create_db

    if db
      db.execute("DELETE FROM packages WHERE nick = ? AND tracknum = ?", nick.downcase, tracknum.upcase)
      result = db.changes
    end
    db.close
    return result
  end
  #End PackageTracking

end
