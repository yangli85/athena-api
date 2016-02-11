require 'api/base_api'

class UserProfileAPI < BaseAPI
  post '/change_avatar' do
    user_id = params['user_id']
    images = params['images']
    result = {
        result: 'success'
    }
    return_response callback, result
  end

  post '/change_name' do
    user_id = params['user_id']
    name = params['name']
    result = {
        result: 'success'
    }
    return_response callback, result
  end

  post '/change_sex' do
    user_id = params['user_id']
    sex = params['sex']
    result = {
        result: 'success'
    }
    return_response callback, result
  end
end



