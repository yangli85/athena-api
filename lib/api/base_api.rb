#encoding:utf-8
require "sinatra"
require "sinatra/jsonp"
require 'sinatra/reloader'
require 'sinatra/cross_origin'
require 'common/logging'
require 'common/helpers'
require 'json'

module API
  class BaseAPI < Sinatra::Application
    EXPIRED = "EXPIRED"
    ERROR = "ERROR"
    SUCCESS = "SUCCESS"

    include Common::Logging
    helpers Sinatra::Jsonp

    use Rack::Session::Cookie, :key => 'athena.rack.session',
        :domain => ENV['DEMAIN'],
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
      'athena api is alive!'
    end
  end
end


