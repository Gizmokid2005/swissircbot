require 'yaml'

module DefineHelpers

  def check_db
    def_file = File.join($confdir, "swissircbot.yml")

    if File.exists?(def_file)
    else
      File.new(def_file, 'wb')
    end

    return def_file

  end

  def save_definition(who, term, meaning)
    df = check_db

  end

  def get_definition(term)
    term = term.downcase
    f = YAML.load_file(check_db)
    termdef = Array.new
    termdef.push(f.fetch(term)['meaning'])
    termdef.push(f.fetch(term)['who'])
  rescue KeyError => e

    return termdef

  end

  def del_definition(term)
    df = check_db
  end

end