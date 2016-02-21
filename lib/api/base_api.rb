require "sinatra"
require "sinatra/jsonp"
require 'sinatra/reloader'
require 'sinatra/cross_origin'
require 'common/logging'
require 'common/helpers'
require 'json'
module API
  class BaseAPI < Sinatra::Application
    include Common::Logging
    helpers Sinatra::Jsonp

    configure do
      enable :logging
      enable :cross_origin if (ENV['RACK_ENV'] == 'development')
      logger = Common::Logging.logger
    end

    get '/' do
      'Athena api is alive!'
    end

    not_found do
      'Sorry, wrong api calls!'
    end

    error do
      'Sorry there was a nasty error'
    end
  end
end


