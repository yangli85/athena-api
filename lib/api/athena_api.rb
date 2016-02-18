require 'api/base_api'
require 'api/advertisement_api'
require 'api/designer_api'
require 'api/shop_api'
require 'api/twitter_api'
require 'api/user_account_api'
require 'api/user_api'
require 'api/user_message_api'
require 'api/user_profile_api'
require 'api/authenticate_api'
require 'api/sms_api'

class AthenaAPI < BaseAPI
  SmsAPI.registered(self)
  AdAPI.registered(self)
  AuthenticateAPI.registered(self)
  DesignerAPI.registered(self)
  ShopAPI.registered(self)
  TwitterAPI.registered(self)
  UserAccountAPI.registered(self)
  UserAPI.registered(self)
  UserMessageAPI.registered(self)
  UserProfileAPI.registered(self)
end