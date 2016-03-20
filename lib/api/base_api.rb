#encoding:utf-8
require "sinatra"
require "sinatra/jsonp"
require 'sinatra/reloader'
require 'sinatra/cross_origin'
require 'common/logging'
require 'common/helpers'
require 'json'
require 'digest/sha1'


module API
  class BaseAPI < Sinatra::Application
    EXPIRED = "EXPIRED"
    include Common::Logging
    helpers Sinatra::Jsonp
    use Rack::Session::Cookie, :key => 'rack.session',
        :domain => '101.200.162.121',
        :path => '/',
        :expire_after => 2592000, # In seconds
        :secret => Digest::SHA256.hexdigest(rand.to_s)

    configure do
      enable :session
      enable :logging
      enable :cross_origin if (ENV['RACK_ENV'] == 'development')
      logger = Common::Logging.logger
    end

    get '/' do
      'api is alive!'
    end

    post '/send_sms' do
      callback = params.delete('callback')
      result = SmsController.call(:send_sms_code, [params['phone_number']])
      return_response callback, result
    end

    get '/login' do
      callback = params.delete('callback') # jsonp
      result = UserController.call(:login, [params['phone_number'], params['code'], params['type']])
      if(result[:data][:status] == "SUCCESS")
        session["user_id"] = result[:data][:user_id]
        session["access_token"] = generate_access_token params['imei_id']
        result.merge!(
            {
                access_token: session[:access_token]
            }
        )
      end
      return_response callback, result
    end

    get '/expired' do
      callback = params.delete('callback')
      result = {
          status: EXPIRED,
          message: "已过期,需要重新登录."
      }
      return_response callback, result
    end

    not_found do
      'Sorry, wrong api calls!'
    end

    error do
      'Sorry there was a nasty error'
    end

    def authenticate
      redirect '/expired' if !session["user_id"] || !session['access_token']
    end

    def generate_access_token imei_id
      raise StandardError.new("no imei id") unless imei_id
      Digest::SHA256.hexdigest imei_id
    end

    def need_authenticate?
      !["/", "/error", "/login", "/not_found", "/expired", "/send_sms", "/favicon.ico"].include?(request.path)
    end
  end
end


