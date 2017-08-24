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

    def banner
      args = if @command.arguments.count > 0
               " #{@command.arguments.map { |a| Dracula::UI.bold("[#{a}]") }.join(" ")}"
             else
               ""
             end

      flags_banner = if @command.flags.count > 0
                       " " + Dracula::UI.bold("[FLAGS]")
                     else
                       ""
                     end

      "#{@command.full_name}#{args}#{flags_banner}"
    end

    def show_usage
      puts "Usage: #{Dracula.program_name} #{banner}"
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
