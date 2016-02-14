require 'rubygems'
require 'database_cleaner'
require 'pandora/models/base'

ENV['RACK_ENV']='test'

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

RSpec.configure do |config|
  config.before :each do
    cleaner = DatabaseCleaner[:active_record, {:model => Pandora::Models::Base}]
    cleaner.strategy = :truncation
    cleaner.clean
  end
end