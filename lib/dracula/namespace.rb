class Dracula
  class Namespace

    attr_accessor :name
    attr_accessor :description
    attr_accessor :commands
    attr_accessor :subcommands
    attr_accessor :parent

    def initialize(klass)
      @klass = klass
      @commands = []
      @subcommands = []
      @parent = []
    end

    def dispatch(route, params, action = :run)
      case route.size
      when 0 then
        action == :run ? run(params) : help
      when 1 then
        handler = commands.find { |c| c.name == route[0] } || subcommands.find { |c| c.name == route[0] }

        if handler
          action == :run ? handler.run(params) : handler.help
        else
          puts Dracula::UI.error("Command not found")
          puts ""
          help
          exit(1)
        end
      else
        handler = subcommands.find { |c| c.name == route[0] }

        if handler
          handler.dispatch(route[1..-1], params, action)
        else
          puts Dracula::UI.error("Command not found #{prefix}#{Dracula::UI.danger(route.join(":"))}")
          puts ""
          help
          exit(1)
        end
      end
    end

    def run(params)
      help
    end

    def prefix
      name ? "#{parent.prefix}#{name}:" : ""
    end

    def top_level?
      prefix == ""
    end

    def help
      NamespaceHelp.new(self).show
    end

    def add_command(command)
      @commands << command
    end

    def add_subcommand(subcommand)
      @subcommands << subcommand
    end

  end
end
