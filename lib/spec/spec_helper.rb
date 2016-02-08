require 'rubygems'
require 'factory_girl'
require 'database_cleaner'

ENV['RACK_ENV']='test'

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

RSpec.configure do |config|
  config.include FactoryGirl::Syntax::Methods

  config.before :each do
    cleaner = DatabaseCleaner
    cleaner.strategy = :truncation
    cleaner.clean
  end
end