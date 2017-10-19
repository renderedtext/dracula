# Dracula — CLI Framework

[![Build Status](https://semaphoreci.com/api/v1/renderedtext/dracula/branches/master/badge.svg)](https://semaphoreci.com/renderedtext/dracula)
[![Gem Version](https://badge.fury.io/rb/dracula.svg)](https://badge.fury.io/rb/dracula)

Dracula is a framework for creating command line application.

The structure of the framework is heavily inspired by Thor, and can be even used
as a drop in replacement for the Thor framework.

Opposed to Thor, Dracula generates a Heroku like interface. For example, a task
management app would have the following interface:

``` txt
app tasks:list
app tasks:info
app calendar:show
app calendar:events:list
app calendar:events:add
```

For help, you can run:

``` txt
app help <command-name>
```

## Hello world example

``` ruby
class CLI < Dracula

  desc "hello", "displays hello messages"
  def hello(message)
    puts "Hi #{message}!"
  end

end

CLI.start(ARGV)
```

```
$ cli hello dracula

Hi dracula!
```

Every method in your class represents a command.

## Command line flags

A command can have one or more command line flags.

``` ruby
class CLI < Dracula

  option :name
  desc "hello", "displays hello messages"
  def hello
    puts "Hi #{options[:name]}!"
  end

end

CLI.start(ARGV)
```

```
$ cli hello --name "Peter"

Hi Peter!
```

The flags are defined above the method.

#### Default values

flags can have default values:

``` ruby
class CLI < Dracula

  option :name, :default => "there"
  desc "hello", "displays hello messages"
  def hello
    puts "Hi #{options[:name]}!"
  end

end

CLI.start(ARGV)
```

```
$ cli hello

Hi there!

$ cli hello --name Peter

Hi Peter!
```

#### Required options

By default, every parameter is optional. You can pass set required to true to
make the option compulsory.

``` ruby
class CLI < Dracula

  option :name, :default => "there", :required => true
  desc "hello", "displays hello messages"
  def hello
    puts "Hi #{options[:name]}!"
  end

end

CLI.start(ARGV)
```

```
$ cli hello

Missing option: --name NAME

$ cli hello --name Peter

Hi Peter!
```

#### Boolean options

By default, the options expect a value to be passed. However, if you set the
type of the option to boolean, only the flag need to be passed:

``` ruby
class CLI < Dracula

  option :json, :type => :boolean
  option :name, :required => true
  desc "hello", "displays hello messages"
  def hello
    if options[:json]
      puts '{ "message": "Hi #{options[:name]}!" }'
    else
      puts "Hi #{options[:name]}!"
    end
  end

end

CLI.start(ARGV)
```

```
$ cli hello --name Peter

Hi Peter!

$ cli hello --name Peter --json

{ "message": "Hi Peter!" }
```

## Namespaces

A CLI application can have subcommands and subnamespaces. For example:

``` ruby
class Greetings < Dracula

  desc "hello", "displays a hello message"
  def hello
    puts "Hi!"
  end

  desc "bye", "displays a bye message"
  def bye
    puts "Bye!"
  end

end

class CLI < Dracula

  desc "suck_blood", "suck blood from innocent victims"
  def suck_blood
    puts "BLOOD!"
  end

  subcommand "greetings", "shows various greetings", Greetings
end

CLI.start(ARGV)
```

```
$ cli suck_blood
BLOOD!

$ cli greetings:hello
Hi!

$ cli greetings:bye
Bye!
```

## Generating JSON structure from your interface

Dracula allows you to generate documentation based on the interface you have
defined in your code. The output is a hash.

An example output generated from the [example CLI interface](spec/example_cli.rb)
is the following:

``` ruby
CLI.docs

=>

{
  :name => "",

  :commands => [
    {
      :name => "login",
      :desc => "Log in to the cli",
      :long_desc => "Log in to the app from the command line.\n",
      :shell => "git login --username USERNAME --password PASSWORD",
      :flags => [
        { :name => "username", :required => true,  :type => "string",  :alias => "u", :default => nil },
        { :name => "password", :required => true,  :type => "string",  :alias => "p", :default => nil },
        { :name => "verbose",  :required => false, :type => "boolean", :alias => "v", :default => false }
      ]
    }
  ],

  :namespaces => [
    :name => "teams",

    :commands => [
      {
        :name => "list",
        :long_desc => "",
        :desc => "List teams in an organization",
        :shell => "git teams:list ORG",
        :flags => []
      },
      {
        :name => "info",
        :long_desc => "",
        :desc => "Show info for a team",
        :shell => "git teams:info TEAM",
        :flags => []
      }
    ],

    :namespaces => [
      :name => "projects",

      :commands => [
        {
          :name => "add",
          :long_desc => "",
          :desc => "Add a project to the team",
          :shell => "git teams:projects:add TEAM PROJECT",
          :flags => []
        },
        {
          :name => "list",
          :desc => "List projects in a team",
          :long_desc => "",
          :shell => "git teams:projects:list TEAM",
          :flags => []
        }
      ],

      :namespaces => []
    ]
  ]
}
```

The output should be suitable for generating markdown or html documentation for
your CLI.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then,
run `rake spec` to run the tests. You can also run `bin/console` for an
interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`.
To release a new version, update the version number in `version.rb`, and then
run `bundle exec rake release`, which will create a git tag for the version,
push git commits and tags, and push the `.gem` file
to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at
<https://github.com/renderedtext/dracula>. This project is intended
to be a safe, welcoming space for collaboration, and contributors are expected
to adhere to the [Contributor Covenant](http://contributor-covenant.org) code
of conduct.

## License

The gem is available as open source under the terms of
the [MIT License](http://opensource.org/licenses/MIT).

