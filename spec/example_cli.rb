class CLI < Dracula
  program_name :git

  option :username, :required => true, :alias => "u", :desc => "Your username"
  option :password, :required => true, :alias => "p", :desc => "Your password"
  option :verbose, :type => :boolean, :alias => "v"
  desc "login", "Log in to the cli"
  long_desc <<-LONGDESC
Log in to the app from the command line.
  LONGDESC
  def login
    if options[:verbose]
      puts "Starting login sequence"
      puts "#{options[:username]} #{options[:password]}"
      puts "Done"
    else
      puts "#{options[:username]}:#{options[:password]}"
    end
  end

  class Teams < Dracula

    desc "list", "List teams in an organization"
    def list(org)
      puts "#{org}/Team A"
      puts "#{org}/Team B"
      puts "#{org}/Team C"
    end

    desc "info", "Show info for a team"
    def info(team)
      "Team info for #{team}"
    end

    class Projects < Dracula

      desc "add", "Add a project to the team"
      def add(team, project)
        "Adding #{project} to the #{team}"
      end

      desc "list", "List projects in a team"
      def list(team)
        puts "Project A"
        puts "Project B"
        puts "Project C"
      end

    end

    register "projects", "Manage projects in a team", Projects

  end

  register "teams", "Manage teams", Teams
end
