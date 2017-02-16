require 'yaml'

module DefineHelpers

  def db_file
    def_file = File.join($confdir, "#{SERVER}_#{NICK}_definitions.yml")
    File.new(def_file, 'wb') unless File.exists?(def_file)
    def_file
  end

  def db
    YAML.load_file(db_file) || {}
  end

  def write_db(definitions)
    File.open(db_file, 'wb') do |f|
      f.write definitions.to_yaml
    end
  end

  def save_definition(who, term, meaning)
    new_db = db.merge(term.downcase => [meaning,who])
    write_db(new_db)
  end

  def get_definition(term)
    if db[term.downcase]
      db[term.downcase][0]
    end
  end

  def del_definition(term)
    new_db = db.dup
    deleted = new_db.delete(term.downcase)
    if deleted
      write_db(new_db)
    end
  end
  def definition_source(term)
    if db[term.downcase]
      db[term.downcase][1]
    end
  end

end
