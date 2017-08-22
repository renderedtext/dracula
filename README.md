# Dracula — CLI Framework

[![Build Status](https://semaphoreci.com/api/v1/renderedtext/dracula/branches/master/badge.svg)](https://semaphoreci.com/renderedtext/dracula)
[![Gem Version](https://badge.fury.io/rb/dracula.svg)](https://badge.fury.io/rb/dracula)

## Usage

First, define your commands:

``` ruby
class Login < Dracula::Command
  flag :username, :short => "u", :required => true
  flag :password, :short => "p", :required => true
  flag :verbose, :short => "v", :type => :boolean

  def run
    if flags[:vebose]
      puts "Running verbosely"
    end

    puts "Logginng in with #{flags[:username]}:#{flags[:password]}"
  end
end
```

``` ruby
Login.run("--username Vlad --password Transylvania")
```
