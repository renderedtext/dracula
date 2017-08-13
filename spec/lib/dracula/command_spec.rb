require "spec_helper"

describe Dracula::Command do
  class Login < Dracula::Command
    flag :username, :short => "u", :required => true
    flag :password, :short => "p", :required => true
    flag :verbose,  :short => "v", :type => :boolean

    def run
      if flags[:verbose]
        "flag username: #{flags[:username]}; flag password: #{flags[:password]}"
      else
        "#{flags[:username]}:#{flags[:password]}"
      end
    end
  end

  it "parses command line flags" do
    result = Login.run(["--username", "Peter", "--password", "Parker"])

    expect(result).to eq("Peter:Parker")
  end

  it "parses short command line flags" do
    result = Login.run(["-u", "Peter", "--password", "Parker"])

    expect(result).to eq("Peter:Parker")
  end

  it "parses boolean flags" do
    result = Login.run(["-u", "Peter", "--password", "Parker", "-v"])

    expect(result).to eq("flag username: Peter; flag password: Parker")

    result = Login.run(["-u", "Peter", "--verbose", "--password", "Parker"])

    expect(result).to eq("flag username: Peter; flag password: Parker")
  end

  class GitRemotes < Dracula::Command
    flag :verbose, :short => "v", :type => :boolean

    def run(name, url)
      "Adding #{name} #{url}"
    end
  end

  it "can parse positinal arguments" do
    expect(GitRemotes.run(["origin", "github.com/shiroyasha/dracula"])).to eq("Adding origin github.com/shiroyasha/dracula")
  end
end