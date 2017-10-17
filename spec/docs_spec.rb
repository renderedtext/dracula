require "spec_helper"

require_relative "example_cli"

RSpec.describe Dracula do

  describe ".docs" do

    it "generates a hash suitable for docs generation" do
      output = {
        :name => "",

        :commands => [
          {
            :name => "login",
            :desc => "Log in to the cli",
            :shell => "git login --username USERNAME --password PASSWORD",
            :options => [
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
              :desc => "List teams in an organization",
              :shell => "git teams:list ORG",
              :options => []
            },
            {
              :name => "info",
              :desc => "Show info for a team",
              :shell => "git teams:info TEAM",
              :options => []
            }
          ],

          :namespaces => [
            :name => "projects",

            :commands => [
              {
                :name => "add",
                :desc => "Add a project to the team",
                :shell => "git teams:projects:add TEAM PROJECT",
                :options => []
              },
              {
                :name => "list",
                :desc => "List projects in a team",
                :shell => "git teams:projects:list TEAM",
                :options => []
              }
            ],

            :namespaces => []
          ]
        ]
      }

      # CLI defined in example_cli.rb
      expect(CLI.docs).to eq(output)
    end
  end
end
