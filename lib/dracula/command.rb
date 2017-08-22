class Dracula
  class Command

    Desc = Struct.new(:name, :description)

    attr_reader :method_name
    attr_reader :desc
    attr_reader :options
    attr_reader :long_desc

    alias_method :flags, :options

    def initialize(klass, method_name, desc, long_desc, options)
      @klass = klass
      @method_name = method_name
      @desc = desc
      @long_desc = long_desc
      @options = options || []
    end

    def name
      desc.name
    end

    def arg_names
      @klass
        .instance_method(@method_name)
        .parameters
        .select { |p| p[0] == :req }
        .map { |p| p[1].to_s.upcase }
        .join(" ")
    end

    def banner
      "#{@klass.namespace.name ? "#{@klass.namespace.name}:" : "" }#{desc.name} #{arg_names}"
    end

    def help
      msg = [
        "Usage: #{Dracula.program_name} #{banner}",
        "",
        "#{desc.description}",
        ""
      ]

      if options.size > 0
        msg << "Flags:"

        options.each { |option| msg << "  #{option.banner}" }

        msg << ""
      end

      unless long_desc.nil?
        msg << long_desc
      end

      puts msg.join("\n")
    end

    def run(params)
      args  = params.take_while { |p| p[0] != "-" }
      parsed_flags = parse_flags(params.drop_while { |p| p[0] != "-" })

      missing_flags = missing_required_flags(parsed_flags)

      unless missing_flags.empty?
        puts "Required Parameter: #{missing_flags.first.banner}"
        puts ""
        help
        exit(1)
      end

      @klass.new(parsed_flags).public_send(method_name, *args)
    rescue OptionParser::MissingArgument => ex
      flag = flags.find { |f| "--#{f.name}" == ex.args.first }

      puts "Parameter has no value: #{flag.banner}"
      puts ""
      help
      exit(1)
    end

    private

    def missing_required_flags(parsed_flags)
      flags.select(&:required?).reject do |flag|
        parsed_flags.keys.include?(flag.name)
      end
    end

    def parse_flags(args)
      parsed_flags = {}

      # set default values
      flags.each do |flag|
        if flag.has_default_value?
          parsed_flags[flag.name] = flag.default_value
        end
      end

      opt_parser = OptionParser.new do |opts|
        flags.each do |flag|
          if flag.boolean?
            short = "-#{flag.short_name}"
            long  = "--#{flag.name}"

            opts.on(short, long, flag.type) do
              parsed_flags[flag.name] = true
            end
          else
            short = "-#{flag.short_name}"
            long  = "--#{flag.name} VALUE"

            opts.on(short, long, flag.type) do |value|
              parsed_flags[flag.name] = value
            end
          end
        end
      end

      opt_parser.parse!(args)

      parsed_flags
    end
  end
end
