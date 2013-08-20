require 'rubygems'
require 'spork'
#uncomment the following line to use spork with the debugger
#require 'spork/ext/ruby-debug'

Spork.prefork do
  # Loading more in this block will cause your tests to run faster. However,
  # if you change any configuration or code from libraries loaded here, you'll
  # need to restart spork for it take effect.

  # This file is copied to spec/ when you run 'rails generate rspec:install'
  require "rails/application"
  require File.expand_path("../../config/environment", __FILE__)
  ENV["RAILS_ENV"] ||= 'test'
  Spork.trap_method(Rails::Application, :reload_routes!)
  Spork.trap_method(Rails::Application::RoutesReloader, :reload!)
  require 'rack/handler/webrick'
  require 'rexml/document'
  require 'tzinfo/definitions/Etc/UTC'
  require 'rails/backtrace_cleaner'
  require 'active_record/connection_adapters/sqlite3_adapter'
  require 'active_support/backtrace_cleaner'
  require 'active_support/core_ext/module/attribute_accessors'
  require 'active_support/core_ext/module/remove_method'
  require 'active_support/core_ext/string/output_safety'
  require 'active_support/core_ext/string/access'
  require 'active_support/core_ext/array/extract_options'
  require 'active_support/core_ext/hash/slice'
  require 'active_support/json'
  require 'multi_json/adapters/json_common'
  require 'multi_json/adapters/json_gem'
  require 'action_dispatch/routing/redirection'
  require 'rspec/rails'
  require 'rspec/mocks'
  require 'rspec/expectations'
  require 'rspec/matchers'
  require 'rspec/core/mocking/with_rspec'
  require 'rspec/core/formatters/progress_formatter'
  require 'rspec/core/formatters/base_text_formatter'
  require 'rspec/core/formatters/documentation_formatter'
  require 'capybara/rspec'
  require 'capybara/rails'
  require 'selenium-webdriver'
  require 'selenium/webdriver/firefox/bridge'
  require 'spork/forker.rb'

  # Requires supporting ruby files with custom matchers and macros, etc,
  # in spec/support/ and its subdirectories.
  Dir[Rails.root.join("spec/support/**/*.rb")].each { |f| require f }

  RSpec.configure do |config|
    config.include FactoryGirl::Syntax::Methods
    config.include Capybara::DSL
    config.treat_symbols_as_metadata_keys_with_true_values = true  
    config.filter_run :focus => true  
    config.run_all_when_everything_filtered = true  
    config.run_all_when_everything_filtered = true
    config.use_transactional_fixtures = false
    config.before :all do
      puts 'cleaning before start'
      cleaning_db
      puts 'cleaning before end'
    end

    # ## Mock Framework
    #
    # If you prefer to use mocha, flexmock or RR, uncomment the appropriate line:
    #
    # config.mock_with :mocha
    # config.mock_with :flexmock
    # config.mock_with :rr

    # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
    #config.fixture_path = "#{::Rails.root}/spec/fixtures"

    # If you're not using ActiveRecord, or you'd prefer not to run each of your
    # examples within a transaction, remove the following line or assign false
    # instead of true.
      
    # If true, the base class of anonymous controllers will be inferred
    # automatically. This will be the default behavior in future versions of
    # rspec-rails.
    config.infer_base_class_for_anonymous_controllers = false

    # Run specs in random order to surface order dependencies. If you find an
    # order dependency and want to debug it, you can fix the order by providing
    # the seed, which is printed after each run.
    #     --seed 1234
    config.order = "random"
  end

  Capybara.register_driver :selenium_firefox do |app|
    client = Selenium::WebDriver::Remote::Http::Default.new
    client.timeout = 12 # <= Page Load Timeout value in seconds
    Capybara::Selenium::Driver.new(app, :browser => :firefox, :http_client => client)
  end
  #module Kernel
  #  def require_with_trace(*args)
  #    start = Time.now.to_f
  #    @indent ||= 0
  #    @indent += 2
  #    require_without_trace(*args)
  #    @indent -= 2
  #    Kernel::puts "#{' '*@indent}#{((Time.now.to_f - start)*1000).to_i} #{args[0]}"
  #  end
  #  alias_method_chain :require, :trace
  #end

end

def cleaning_db
  conf = ActiveRecord::Base.configurations[::Rails.env]
  connection = ActiveRecord::Base.connection
  connection.disable_referential_integrity do
    connection.tables.each do |table_name|
      next if table_name == "schema_migrations"
      next if connection.select_value("SELECT count(*) FROM #{table_name}") == 0
      case conf["adapter"]
      when "mysql", "mysql2", "postgresql"
        connection.execute("TRUNCATE #{table_name}")
      when "sqlite", "sqlite3"
        connection.execute("DELETE FROM #{table_name}")
        connection.execute("DELETE FROM sqlite_sequence where name='#{table_name}'")
      end
    end
  end
  connection.execute("VACUUM") if conf["adapter"] == "sqlite3"
end
Spork.each_run do
  FactoryGirl.reload 
  # This code will be run each time you run your specs.
end

# --- Instructions ---
# Sort the contents of this file into a Spork.prefork and a Spork.each_run
# block.
#
# The Spork.prefork block is run only once when the spork server is started.
# You typically want to place most of your (slow) initializer code in here, in
# particular, require'ing any 3rd-party gems that you don't normally modify
# during development.
#
# The Spork.each_run block is run each time you run your specs.  In case you
# need to load files that tend to change during development, require them here.
# With Rails, your application modules are loaded automatically, so sometimes
# this block can remain empty.
#
# Note: You can modify files loaded *from* the Spork.each_run block without
# restarting the spork server.  However, this file itself will not be reloaded,
# so if you change any of the code inside the each_run block, you still need to
# restart the server.  In general, if you have non-trivial code in this file,
# it's advisable to move it into a separate file so you can easily edit it
# without restarting spork.  (For example, with RSpec, you could move
# non-trivial code into a file spec/support/my_helper.rb, making sure that the
# spec/support/* files are require'd from inside the each_run block.)
#
# Any code that is left outside the two blocks will be run during preforking
# *and* during each_run -- that's probably not what you want.
#
# These instructions should self-destruct in 10 seconds.  If they don't, feel
# free to delete them.





