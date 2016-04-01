$LOAD_PATH << File.expand_path('./lib', File.dirname(__FILE__))
require 'athena_api'
require 'common/environment_variables'

REQUIRED_ENVIRONMENT_VARIABLES = [
    'PANDORA_DATABASE_ADAPTER',
    'PANDORA_DATABASE_NAME',
    'PANDORA_DATABASE_HOST',
    'PANDORA_DATABASE_USERNAME',
    'PANDORA_DATABASE_PASSWORD',
    'TEMP_IMAGES_FOLDER',
    'IMGAES_FOLDER',
    'DEMAIN',
    'DOWNLOAD_URL',
    'WX_APP_ID',
    'WX_API_KEY',
    'WX_MCH_ID',
    'ALI_MCH_ID'
].freeze
Common::EnvironmentVariables.check(REQUIRED_ENVIRONMENT_VARIABLES)
AthenaAPI.run! :port => 8080, :bind => '0.0.0.0'