$LOAD_PATH << File.expand_path('./lib', File.dirname(__FILE__))
require 'api/advertisement_api'
require 'api/designer_api'
require 'api/shop_api'
require 'api/twitter_api'
require 'api/user_account_api'
require 'api/user_api'
require 'api/user_message_api'
require 'api/user_profile_api'
require 'api/authenticate_api'
run AuthenticateAPI.new AdvertisementAPI.new DesignerAPI.new ShopAPI.new TwitterAPI.new UserAccountAPI.new UserAPI.new UserMessageAPI.new UserProfileAPI.new
# run AdvertisementAPI.new
