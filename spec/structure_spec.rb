require "spec_helper"

require_relative "example_cli"

RSpec.describe Dracula::Structure do

  describe ".structure" do

    it "generates a hash suitable for docs generation" do
      output = {
        :name => "",

        :commands => [
          {
            :name => "login",
            :desc => "Log in to the cli",
            :long_desc => "Log in to the app from the command line.\n",
            :shell => "git login --username USERNAME --password PASSWORD",
            :flags => [
              { :name => "username", :required => true,  :type => "string",  :alias => "u", :default => nil, :desc => "Your username" },
              { :name => "password", :required => true,  :type => "string",  :alias => "p", :default => nil, :desc => "Your password" },
              { :name => "verbose",  :required => false, :type => "boolean", :alias => "v", :default => false, :desc => "" }
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

      # CLI defined in example_cli.rb
      expect(CLI.structure).to eql(output)
    end
  end
end
