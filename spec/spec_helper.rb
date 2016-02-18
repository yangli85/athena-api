require 'rubygems'
require 'factory_girl'
require 'database_cleaner'

ENV['RACK_ENV']='test'

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

require 'factories/user'
require 'factories/image'
require 'factories/account'
require 'factories/account_log'
require 'factories/sms_code'
require 'factories/ad_image'
require 'factories/twitter_image'
require 'factories/twitter'
require 'factories/shop'
require 'factories/designer'
require 'factories/vita'
require 'factories/vita_image'
require 'factories/message'
require 'factories/favorite_image'
require 'factories/favorite_designer'

RSpec.configure do |config|
  config.include FactoryGirl::Syntax::Methods

  config.before :each do
    cleaner = DatabaseCleaner[:active_record, {:model => Pandora::Models::Base}]
    cleaner.strategy = :truncation
    cleaner.clean
  end
end