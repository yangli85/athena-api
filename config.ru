$LOAD_PATH << File.expand_path('./lib', File.dirname(__FILE__))
require 'api/athena_api'
AthenaAPI.run! :port => 8080, :bind => '0.0.0.0'