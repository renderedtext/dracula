require "spec_helper"

require_relative "example_cli"

RSpec.describe Dracula do
  def catch_exit
    yield
    0
  rescue SystemExit => e
    e.status
  end

  it "has a version number" do
    expect(Dracula::VERSION).not_to be nil
  end

  describe "Help Screens" do
    describe "main help screen" do
      it "lists the commands and subtopics" do
        msg = [
          "Usage: git [command]",
          "",
          "Command list, type git help [command] for more details:",
          "",
          "  login  Log in to the cli",
          "",
          "  teams  Manage teams",
          ""
        ].join("\n")

        stdout, stderr = collect_output { CLI.start(["help"]) }

        expect(stdout).to eq(msg)
        expect(stderr).to eq("")
      end
    end

    describe "command help" do
      it "shows the usage, flags, and long description" do
        msg = [
          "Usage: git login [FLAGS]",
          "",
          "Log in to the cli",
          "",
          "Flags:",
          "  -u USERNAME, --username USERNAME",
          "  -p PASSWORD, --password PASSWORD",
          "  -v, --verbose",
          "",
          "Log in to the app from the command line."
        ].join("\n")

        stdout, stderr = collect_output { CLI.start(["help", "login"]) }

        expect(stdout).to eq(msg)
        expect(stderr).to eq("")
      end
    end

    describe "subnamespace help" do
      it "displays help for a subnamespace" do
        msg = [
          "Usage: git teams:[command]",
          "",
          "Manage teams",
          "",
          "Command list, type git help teams:[command] for more details:",
          "",
          "  teams:list           List teams in an organization",
          "  teams:info           Show info for a team",
          "",
          "  teams:projects:add   Add a project to the team",
          "  teams:projects:list  List projects in a team",
          ""
        ].join("\n")

        stdout, stderr = collect_output { CLI.start(["help", "teams"]) }

        expect(stdout).to eq(msg)
        expect(stderr).to eq("")
      end
    end

    describe "subcommand help" do
      it "displays help for a subcommand" do
        msg = [
          "Usage: git teams:info [TEAM]",
          "",
          "Show info for a team"
        ].join("\n")

        stdout, stderr = collect_output { CLI.start(["help", "teams:info"]) }

        expect(stdout).to eq(msg)
        expect(stderr).to eq("")
      end
    end
  end

  describe "Invoking commands" do
    it "can invoke simple commands" do
      msg = [
        "Peter:Parker",
        ""
      ].join("\n")

      expect { CLI.start(["login", "--username", "Peter", "--password", "Parker"]) }.to output(msg).to_stdout
    end

    it "can invoke nested commands"  do
      msg = [
        "X/Team A",
        "X/Team B",
        "X/Team C",
        ""
      ].join("\n")

      expect { CLI.start(["teams:list", "X"]) }.to output(msg).to_stdout
    end
  end

  describe "Flags" do
    it "can parse string flags" do
      cli = Class.new(Dracula) do

        option :name
        desc "hello", "testing"
        def hello
          puts options[:name]
        end

      end

      expect { cli.start(["hello", "--name", "Clark"]) }.to output(/Clark/).to_stdout
    end

    it "can parse boolean flags" do
      cli = Class.new(Dracula) do

        option :json, :type => :boolean
        desc "hello", "testing"
        def hello
          puts options[:json]
        end

      end

      expect { cli.start(["hello", "--json"]) }.to output(/true/).to_stdout
      expect { cli.start(["hello"]) }.to output(/false/).to_stdout
    end

    it "sets default values" do
      cli = Class.new(Dracula) do

        option :json, :type => :boolean, :default => true
        option :yaml, :type => :boolean, :default => false
        option :name, :default => "peter"
        option :age
        desc "hello", "testing"
        def hello
          puts "#{options[:json]}, #{options[:yaml]}, #{options[:name]}, #{options[:age]}"
        end

      end

      expect { cli.start(["hello", "--json"]) }.to output(/true, false, peter,/).to_stdout
    end

    describe "flags that expect parameters" do
      before do
        @cli = Class.new(Dracula) do

          option :name
          desc "hello", "testing"
          def hello
            puts "#{options[:name]}"
          end

        end
      end

      context "when the parameter is not passed" do
        it "displays an error and the help screen of the command" do
          msg = [
            "[ERROR] Missing flag parameter: --name NAME",
            "",
            "Usage: git hello [FLAGS]",
            "",
            "Testing",
            "",
            "Flags:",
            "  --name NAME"
          ].join("\n")

          expect(catch_exit { @cli.start(["hello", "--name"]) }).to eq(1)

          stdout, stderr = collect_output { @cli.start(["hello", "--name"]) }

          expect(stdout).to eq(msg)
          expect(stderr).to eq("")
        end
      end

      context "when the parameter is passed" do
        it "parses the parameter and executes the command" do
          msg = [
            "Jack",
            ""
          ].join("\n")

          expect { @cli.start(["hello", "--name", "Jack"]) }.to output(msg).to_stdout
        end
      end
    end

    it "sets default values" do
      cli = Class.new(Dracula) do

        option :json, :type => :boolean, :default => true
        option :yaml, :type => :boolean, :default => false
        option :name, :default => "peter"
        option :age
        desc "hello", "testing"
        def hello
          puts "#{options[:json]}, #{options[:yaml]}, #{options[:name]}, #{options[:age]}"
        end

      end

      expect { cli.start(["hello", "--json"]) }.to output(/true, false, peter,/).to_stdout
    end

    describe "required params" do
      context "required param is passed to the command" do
        it "displays an error and the command's help" do
          cli = Class.new(Dracula) do

            option :message, :required => true
            desc "hello", "testing"
            def hello
              puts "#{options[:message]}"
            end

          end

          expect { cli.start(["hello", "--message", "yo"]) }.to output("yo\n").to_stdout
        end
      end

      context "required param is not passed" do
        it "displays an error and the command's help" do
          cli = Class.new(Dracula) do
            option :message, :required => true
            desc "hello", "testing"
            def hello
              puts "#{options[:message]}"
            end
          end

          msg = [
            "[ERROR] Missing required Parameter: --message MESSAGE",
            "",
            "Usage: git hello [FLAGS]",
            "",
            "Testing",
            "",
            "Flags:",
            "  --message MESSAGE"
          ].join("\n")

          expect(catch_exit { cli.start(["hello"]) }).to eq(1)

          stdout, stderr = collect_output { cli.start(["hello"]) }

          expect(stdout).to eq(msg)
          expect(stderr).to eq("")
        end
      end
    end

    context "passing unrecognized parameters" do
      it "displays an error and the command's help" do
        cli = Class.new(Dracula) do
          option :message, :required => true
          desc "hello", "testing"
          def hello
            puts "#{options[:message]}"
          end
        end

        msg = [
          "[ERROR] Unrecognized Parameter: --from",
          "",
          "Usage: git hello [FLAGS]",
          "",
          "Testing",
          "",
          "Flags:",
          "  --message MESSAGE"
        ].join("\n")

        expect(catch_exit { cli.start(["hello", "--from", "1"]) }).to eq(1)

        stdout, stderr = collect_output { cli.start(["hello", "--from", "1"]) }

        expect(stdout).to eq(msg)
        expect(stderr).to eq("")
      end
    end
  end

  describe "command arguments" do
    context "when arguments are not passed" do
      it "displays an error and shows the help screen" do
        cli = Class.new(Dracula) do
          desc "hello", "testing"
          def hello(message)
            puts message
          end
        end

        msg = [
          "[ERROR] Missing arguments",
          "",
          "Usage: git hello [MESSAGE]",
          "",
          "Testing"
        ].join("\n")

        expect(catch_exit { cli.start(["hello"]) }).to eq(1)

        stdout, stderr = collect_output { cli.start(["hello"]) }

        expect(stdout).to eq(msg)
        expect(stderr).to eq("")
      end
    end

    context "too many arguments are passed" do
      it "displays an error and shows the help screen" do
        cli = Class.new(Dracula) do
          desc "hello", "testing"
          def hello(message)
            puts message
          end
        end

        msg = [
          "[ERROR] Missing arguments",
          "",
          "Usage: git hello [MESSAGE]",
          "",
          "Testing"
        ].join("\n")

        expect(catch_exit { cli.start(["hello", "a", "b"]) }).to eq(1)

        stdout, stderr = collect_output { cli.start(["hello"]) }

        expect(stdout).to eq(msg)
        expect(stderr).to eq("")
      end
    end
  end
end
