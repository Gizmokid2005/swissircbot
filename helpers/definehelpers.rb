require 'yaml'

module DefineHelpers

  def check_db
    def_file = File.join($confdir, "#{SERVER}_#{NICK}_definitions.yml")

    if File.exists?(def_file)
    else
      File.new(def_file, 'wb')
    end

    return def_file

  end

  def save_definition(who, term, meaning)
    df = check_db
    defhash = Hash.new
    defhash[term.downcase] = meaning

    File.open(df, 'wb') { |f| f.write defhash.to_yaml }
  end

  def get_definition(term)
    term = term.downcase
    df = YAML.load_file(check_db)
    termdef = df.fetch(term)

  rescue KeyError => e

    return termdef

  end

  def del_definition(term)
    term = term.downcase
    df = YAML.load_file(check_db)
    deleted = df.delete(term)
    if deleted
      File.open(check_db, 'wb') { |f| f.write df.to_yaml}
    end

  rescue KeyError => e

  end

end
