require 'api/base_api'

class UserAccountAPI < BaseAPI
  get '/account_info' do
    user_id =params['user_id']
    callback = params.delete('callback') # jsonp
    result = {
        stars: 10
    }
    return_response callback, result
  end

  get '/account_log' do
    user_id = params['user_id']
    callback = params.delete('callback') # jsonp
    result = [
        {
            stars: 10,
            details: "Tommy赠送给你",
            created_at: '2014-12-12 12:12:12'
        },
        {
            stars: -2,
            details: "你奖励给Tommy",
            created_at: '2014-12-12 12:12:12'
        }
    ]
    return_response callback, result
  end

  post '/buy_stars' do
    user_id = params['user_id']
    stars = params['stars']
    channel = params['channel']
    callback = params.delete('callback') # jsonp
    result = {
        result: 'success'
    }
    return_response callback, result
  end

  post '/give_stars' do
    user_id = params['user_id']
    to_user_id = params['to_user_id']
    stars = params['stars']
    callback = params.delete('callback') # jsonp
    result = {
        result: 'success'
    }
    return_response callback, result
  end
end



