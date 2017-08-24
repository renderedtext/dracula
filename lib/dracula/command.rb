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

    def arguments
      @klass.instance_method(@method_name).parameters.select { |p| p[0] == :req }.map { |p| p[1].to_s.upcase }
    end

    def banner
      namespace = @klass.namespace.name ? "#{@klass.namespace.name}:" : ""
      args = arguments.count > 0 ? " #{arguments.map { |a| Dracula::UI.bold("[#{a}]") }.join(" ")}" : ""
      flags_banner = flags.count > 0 ? " " + Dracula::UI.bold("[FLAGS]") : ""

      "#{namespace}#{desc.name}#{args}#{flags_banner}"
    end

    def help
      CommandHelp.new(self).show
    end

    def run(params)
      args = params.take_while { |p| p[0] != "-" }

      if args.count < arguments.count
        puts Dracula::UI.error("Missing arguments")
        puts ""
        help
        exit(1)
      end

      if args.count > arguments.count
        puts Dracula::UI.error("Too many arguments")
        puts ""
        help
        exit(1)
      end

      parsed_flags = parse_flags(params.drop_while { |p| p[0] != "-" })

      missing_flags = missing_required_flags(parsed_flags)

      unless missing_flags.empty?
        puts Dracula::UI.error("Missing required Parameter: #{missing_flags.first.banner}")
        puts ""
        help
        exit(1)
      end

      @klass.new(parsed_flags).public_send(method_name, *args)
    rescue OptionParser::MissingArgument => ex
      flag = flags.find { |f| "--#{f.name}" == ex.args.first }

      puts Dracula::UI.error("Missing flag parameter: #{flag.banner}")
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
