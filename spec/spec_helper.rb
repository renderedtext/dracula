require "bundler/setup"
require "dracula"

def collect_output
  original_stdout = $stdout
  original_stderr = $stderr

  $stdout = fake_stdout = StringIO.new
  $stderr = fake_stderr = StringIO.new

  result = yield

  [stripped_output(fake_stdout.string.to_s), stripped_output(fake_stderr.string.to_s), result]
rescue SystemExit
  [stripped_output(fake_stdout.string.to_s), stripped_output(fake_stderr.string.to_s), result]
ensure
  $stdout = original_stdout
  $stderr = original_stderr
end

def stripped_output(str)
  str.split("\n").map(&:rstrip).join("\n")
end

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
