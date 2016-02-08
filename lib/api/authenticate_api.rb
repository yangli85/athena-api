require 'api/base_api'

class AuthenticateAPI < BaseAPI
  get '/sms' do
    logger.info("Will send validate code to #{params['phone_number']}.")
    callback = params.delete('callback') # jsonp
    result = {result: 'success'}
    logger.info("Validate code for #{params['phone_number']} was sent.")
    return_response callback, result
  end

  get '/login' do
    callback = params.delete('callback') # jsonp
    result = {
        validate_result: 'success',
        user_id: 1,
        is_new: true
    }
    return_response callback, result
  end
end



