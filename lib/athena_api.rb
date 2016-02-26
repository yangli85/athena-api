require 'api/base_api'
require 'api/ad_api'
require 'api/designer_api'
require 'api/user_api'
require 'api/sms_api'
require 'api/twitter_api'
require 'api/commissioner_api'

class AthenaAPI < API::BaseAPI
  API::SmsAPI.registered(self)
  API::AdAPI.registered(self)
  API::DesignerAPI.registered(self)
  API::TwitterAPI.registered(self)
  API::UserAPI.registered(self)
  API::CommissionerAPI.registered(self)
end