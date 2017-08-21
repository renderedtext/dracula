require "dracula/version"
require "optparse"

class Dracula
  require "dracula/command"
  require "dracula/flag"
  require "dracula/namespace"
  require "dracula/ui"

  class << self
    def program_name(name = nil)
      if name.nil?
        @@program_name || "dracula" # getter
      else
        @@program_name = name       # setter
      end
    end

    def start(args)
      if args.empty? || (args.size == 1 && args[0] == "help")
        namespace.help
      else
        action = args[0] == "help" ? :help : :run

        if args[0] == "help"
          action = :help

          args.shift # drop 'help'

          command = args.shift
          params  = args
        else
          action = :run
          command = args.shift
          params  = args
        end

        namespace.dispatch(command.split(":"), params, action)
      end
    end

    def namespace
      @namespace ||= Dracula::Namespace.new(self)
    end

    def option(name, params = {})
      @options ||= []
      @options << Dracula::Flag.new(name, params)
    end

    def long_desc(description)
      @long_desc = description
    end

    def desc(name, description)
      @desc = Command::Desc.new(name, description)
    end

    def register(name, description, klass)
      klass.namespace.name = name
      klass.namespace.description = description

      namespace.add_subcommand(klass.namespace)
    end

    private

    def method_added(method_name)
      command = Command.new(self, method_name, @desc, @long_desc, @options)

      @desc = nil
      @long_desc = nil
      @options = nil

      namespace.add_command(command)
    end
  end

  attr_reader :options

  def initialize(options = {})
    @options = options
  end

end
