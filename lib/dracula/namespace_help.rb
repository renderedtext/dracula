class Dracula
  class NamespaceHelp

    attr_reader :namespace

    def initialize(namespace)
      @namespace = namespace
    end

    def show
      show_usage
      show_desc if namespace.description
      show_commands
    end

    private

    def show_usage
      puts "Usage: #{Dracula.program_name} #{Dracula::UI.bold "#{namespace.prefix}[command]"}\n"
      puts ""
    end

    def show_desc
      puts namespace.description.capitalize
      puts ""
    end

    def show_commands
      puts "Command list, type #{Dracula::UI.bold(Dracula.program_name.to_s + " help #{namespace.prefix}[command]")} for more details:"
      puts ""

      banners = []

      banners += command_banners(namespace)
      banners << ["", ""] # empty line

      if namespace.top_level?
        banners += short_subcommand_banners(namespace)
        banners << ["", ""] # empty line
      else
        namespace.subcommands.each do |sub_cmd|
          banners += command_banners(sub_cmd)
          banners << ["", ""] # empty line
        end
      end

      Dracula::UI.print_table(banners, :indent => 2)
    end

    def short_subcommand_banners(namespace)
      namespace.subcommands.map do |sub_cmd|
        [Dracula::UI.bold("#{namespace.prefix}#{sub_cmd.name}"), sub_cmd.description.capitalize]
      end
    end

    def command_banners(namespace)
      namespace.commands.map do |cmd|
        [Dracula::UI.bold("#{namespace.prefix}#{cmd.desc.name}"), cmd.desc.description.capitalize]
      end
    end

  end
end
