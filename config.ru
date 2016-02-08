$LOAD_PATH << File.expand_path('./lib', File.dirname(__FILE__))
require 'api/authenticate_api'
run AuthenticateAPI.new
