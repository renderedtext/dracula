class Dracula
  class Docs

    attr_reader :namespace

    def initialize(namespace)
      @namespace = namespace
    end

    def generate
      {
        :name => namespace.name.to_s,
        :commands => @namespace.commands.map { |c| command_docs(c) },
        :namespaces => @namespace.subcommands.map { |sc| Dracula::Docs.new(sc).generate }
      }
    end

    private

    def command_docs(command)
      {
        :name => command.name,
        :desc => command.description,
        :shell => command_shell(command),
        :options => command.options.map do |option|
          {
            :name => option.name.to_s,
            :required => option.required?,
            :type => option.type.to_s,
            :alias => option.alias_name,
            :default => option.default_value
          }
        end
      }
    end

    def command_shell(command)
      args = command.arguments.join(" ")
      options = command.options.select(&:required?).map(&:long_name_banner).join(" ")

      [Dracula.program_name, command.full_name, args, options].select { |element| element != "" }.join(" ")
    end

  end
end
