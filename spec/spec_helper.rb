require 'bundler/setup'
require 'grape_crud'
require 'grape'

Bundler.require :default, :test

Dir["#{File.dirname(__FILE__)}/support/*.rb"].each do |file|
  require file
end

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.include Rack::Test::Methods
  config.raise_errors_for_deprecations!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.before(:each) { Grape::Util::InheritableSetting.reset_global! }
  config.after(:each) { Article.destroy_all }
end
