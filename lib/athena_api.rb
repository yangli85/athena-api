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
  before do
    authenticate if need_authenticate?
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
      UserController.new.create_or_update_access_token user_id, new_access_token
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
    old_access_token = UserController.new.get_access_token user_id
    redirect '/no_authenticate' if user_id.nil? || identity_id.nil? || old_access_token != generate_access_token(identity_id)
  end

  def generate_access_token identity_id
    session['access_token'] = Digest::SHA256.hexdigest identity_id
  end

  def need_authenticate?
    if params['source'] == "share" && ["/search_twitter", "/add_promotion_log"].include?(request.path)
      false
    elsif request.path.include? "/commissioner/"
      false
    elsif request.path.include? "/notify/"
      false
    else
      !["/", "/login", "/no_authenticate", "/no_identity_id", "/send_login_sms", "/favicon.ico"].include?(request.path)
    end
  end
end