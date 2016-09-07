#encoding:utf-8
require "sinatra"
require "sinatra/jsonp"
require 'sinatra/reloader'
require 'sinatra/cross_origin'
require 'common/logging'
require 'common/helpers'
require 'json'
require "rack/session/redis"

module API
  class BaseAPI < Sinatra::Application
    EXPIRED = "EXPIRED"
    ERROR = "ERROR"
    SUCCESS = "SUCCESS"

    include Common::Logging
    helpers Sinatra::Jsonp
    
    use Rack::Session::Redis, {
        :url          => "redis://localhost:6379",
        :namespace    => "rack:session",
        :expire_after => 7776000
    }

    configure do
      enable :session
      enable :logging
      enable :cross_origin if (ENV['RACK_ENV'] == 'development')
      logger = Common::Logging.logger
    end

    get '/' do
      'athena api is alive!'
    end
  end
end


