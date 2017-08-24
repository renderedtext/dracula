class Dracula
  class CommandHelp

    def initialize(command)
      @command = command
    end

    def show
      show_usage
      show_desc
      show_flags     if @command.flags.any?
      show_long_desc if @command.long_desc
    end

    private

    def show_usage
      puts "Usage: #{Dracula.program_name} #{@command.banner}"
      puts ""
    end

    def show_desc
      puts @command.desc.description.capitalize
      puts ""
    end

    def show_flags
      puts Dracula::UI.bold("Flags:")

      @command.flags.each { |flag| puts "  #{flag.banner}" }

      puts ""
    end

    def show_long_desc
      puts @command.long_desc
    end

  end
end
