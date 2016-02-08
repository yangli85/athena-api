$LOAD_PATH << File.expand_path('./lib', File.dirname(__FILE__))
require 'api/authenticate_api'
AuthenticateAPI.run! :port => 9292, :bind => '0.0.0.0'
