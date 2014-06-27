require 'singleton'

module GoogleImageApi
  class Configuration
    include Singleton

    def self.directives(*directives)
      directives.each do |directive|
        define_method directive do |*args|
          if args.empty?
            return instance_variable_get("@#{directive}")
          else
            instance_variable_set("@#{directive}", args.first)
          end
        end
      end
    end

    def self.[](directive)
      instance.send(directive)
    end

    directives :key
  end
end
