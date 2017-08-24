class Dracula
  class Namespace

    attr_accessor :name
    attr_accessor :description
    attr_accessor :commands
    attr_accessor :subcommands

    def initialize(klass)
      @klass = klass
      @commands = []
      @subcommands = []
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
          help
        end
      else
        handler = subcommands.find { |c| c.name == route[0] }

        if handler
          handler.dispatch(route[1..-1], params, action)
        else
          help
        end
      end
    end

    def run(params)
      help
    end

    def prefix
      name ? "#{name}:" : ""
    end

    def top_level?
      prefix == ""
    end

    def help
      default_desc = "Command list, type #{Dracula::UI.bold(Dracula.program_name + " help COMMAND")} for more details:"

      puts "Usage: #{Dracula.program_name} #{Dracula::UI.bold "#{prefix}[command]"}"
      puts ""
      puts (description || default_desc).capitalize
      puts ""

      banners = []

      commands.each do |cmd|
        banners << [Dracula::UI.bold("#{prefix}#{cmd.desc.name}"), cmd.desc.description.capitalize]
      end

      banners << ["", ""] # empty line

      if top_level?
        # show only namespaces

        subcommands.each do |sub_cmd|
          banners << [Dracula::UI.bold("#{prefix}#{sub_cmd.name}"), sub_cmd.description.capitalize]
        end

        banners << ["", ""] # empty line
      else
        # show namespaces with commands

        subcommands.each do |sub_cmd|
          sub_cmd.commands.each do |cmd|
            banners << [Dracula::UI.bold("#{prefix}#{sub_cmd.prefix}#{cmd.desc.name}"), cmd.desc.description.capitalize]
          end

          banners << ["", ""] # empty line
        end
      end

      Dracula::UI.print_table(banners, :indent => 2)
    end

    def add_command(command)
      @commands << command
    end

    def add_subcommand(subcommand)
      @subcommands << subcommand
    end

  end
end
