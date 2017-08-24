class Dracula
  class NamespaceHelp

    attr_reader :namespace

    def initialize(namespace)
      @namespace = namespace
    end

    def show
      puts "Usage: #{Dracula.program_name} #{Dracula::UI.bold "#{namespace.prefix}[command]"}\n"
      puts ""

      if namespace.description
        puts namespace.description.capitalize
        puts ""
      end

      puts "Command list, type #{Dracula::UI.bold(Dracula.program_name.to_s + " help #{namespace.prefix}[command]")} for more details:"
      puts ""

      banners = []

      namespace.commands.each do |cmd|
        banners << [Dracula::UI.bold("#{namespace.prefix}#{cmd.desc.name}"), cmd.desc.description.capitalize]
      end

      banners << ["", ""] # empty line

      if namespace.top_level?
        # show only namespaces

        namespace.subcommands.each do |sub_cmd|
          banners << [Dracula::UI.bold("#{namespace.prefix}#{sub_cmd.name}"), sub_cmd.description.capitalize]
        end

        banners << ["", ""] # empty line
      else
        # show namespaces with commands

        namespace.subcommands.each do |sub_cmd|
          sub_cmd.commands.each do |cmd|
            banners << [Dracula::UI.bold("#{sub_cmd.prefix}#{cmd.desc.name}"), cmd.desc.description.capitalize]
          end

          banners << ["", ""] # empty line
        end
      end

      Dracula::UI.print_table(banners, :indent => 2)
    end

  end
end
