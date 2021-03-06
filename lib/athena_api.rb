require 'api/base_api'
require 'api/ad_api'
require 'api/designer_api'
require 'api/user_api'
require 'api/twitter_api'
require 'api/commissioner_api'
require 'api/pay_api'
require 'digest/sha1'
require 'controllers/sms_controller'

class AthenaAPI < API::BaseAPI
  PUBLIC_API = ["/", "/login", "/no_authenticate", "/no_identity_id", "/ali_notify", "/wx_notify", "/search_twitter", "/send_login_sms", "/favicon.ico"]
  ActiveRecord::Base.default_timezone = :local

  before do
    authenticate unless is_public_api? request.path
  end

  API::AdAPI.registered(self)
  API::DesignerAPI.registered(self)
  API::TwitterAPI.registered(self)
  API::UserAPI.registered(self)
  API::CommissionerAPI.registered(self)
  API::PayAPI.registered(self)

  get '/login' do
    callback = params.delete('callback') # jsonp
    identity_id = params.delete("identity_id")
    redirect "/no_identity_id" if identity_id.nil? || identity_id.strip==""
    result = UserController.call(:login, [params['phone_number'], params['code'], params['type']])
    if (result[:status] == "SUCCESS")
      user_id = result[:data][:user_id]
      new_access_token = generate_access_token identity_id
      UserController.call(:create_or_update_access_token, [user_id, new_access_token])
      session['user_id'] = user_id
      session['identity_id'] = identity_id
    end
    return_response callback, result
  end

  post '/send_login_sms' do
    callback = params.delete('callback')
    result = SmsController.call(:send_login_sms_code, [params['phone_number']])
    return_response callback, result
  end

  get '/no_authenticate' do
    callback = params.delete('callback')
    return_response callback, {status: "EXPIRED", message: "need login"}
  end

  get '/no_identity_id' do
    callback = params.delete('callback')
    return_response callback, {status: "ERROR", message: "need identity id"}
  end

  private
  def authenticate
    user_id = session['user_id']
    identity_id = session['identity_id']
    redirect '/no_authenticate' if authenticate_failed? user_id, identity_id
  end

  def authenticate_failed? user_id, identity_id
    old_access_token = get_user_access_token user_id
    new_access_token = generate_access_token identity_id
    status = user_id.nil? || identity_id.nil? || old_access_token != new_access_token
    logger.error("no authenticate for user:#{user_id} with identity_id:#{identity_id},old_token:#{old_access_token},new_token:#{new_access_token}") if status
    status
  end

  def generate_access_token identity_id
    session['access_token'] = Digest::SHA256.hexdigest identity_id unless identity_id.nil?
  end

  def get_user_access_token user_id
    access_token = UserController.new.get_access_token user_id
    logger.error("can not get access token for user:#{user_id}") if access_token.nil?
    access_token
  end

  def is_public_api? path
    path.include?("/commissioner/") || PUBLIC_API.include?(path)
  end
end