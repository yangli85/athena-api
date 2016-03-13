# encoding: UTF-8
require 'controllers/user_controller'
module API
  class UserAPI
    def self.registered(app)

      app.get '/login' do
        callback = params.delete('callback') # jsonp
        result = UserController.call(:login, [params['phone_number'], params['code'], params['type']])
        return_response callback, result
      end

      app.get '/consumer_details' do
        callback = params.delete('callback') # jsonp
        result = UserController.call(:get_user_details, [params['user_id'].to_i])
        return_response callback, result
      end

      app.post '/upload_image' do
        callback = params.delete('callback') # jsonp
        result = UserController.call(:upload_image, [params['image_base64']])
        return_response callback, result
      end

      app.post '/publish_twitter' do
        callback = params.delete('callback') # jsonp
        image_paths = params['image_paths'].split(",")
        args = [params['author_id'].to_i, params['designer_id'].to_i, params['content'], image_paths, params['stars'].to_i, params['latitude'], params['longitude']]
        result = UserController.call(:publish_new_twitter, args)
        return_response callback, result
      end

      app.post '/add_favorite_image' do
        callback = params.delete('callback') # jsonp
        result = UserController.call(:add_favorite_image, [params['twitter_id'].to_i, params['user_id'].to_i, params['image_id'].to_i])
        return_response callback, result
      end

      app.post '/del_favorite_images' do
        ids = params["ids"].split(',').map(&:to_i)
        callback = params.delete('callback') # jsonp
        result = UserController.call(:del_favorite_images, [ids])
        return_response callback, result
      end

      app.post '/del_favorite_image' do
        callback = params.delete('callback') # jsonp
        result = UserController.call(:del_favorite_image, [params['user_id'].to_i, params['image_id'].to_i])
        return_response callback, result
      end

      app.get '/favorite_images' do
        callback = params.delete('callback') # jsonp
        result = UserController.call(:favorite_images, [params['user_id'].to_i])
        return_response callback, result
      end

      app.post '/add_favorite_designer' do
        callback = params.delete('callback') # jsonp
        result = UserController.call(:add_favorite_designer, [params['user_id'].to_i, params['designer_id'].to_i])
        return_response callback, result
      end

      app.post '/del_favorite_designers' do
        ids = params["ids"].split(',').map(&:to_i)
        callback = params.delete('callback') # jsonp
        result = UserController.call(:del_favorite_designers, [ids])
        return_response callback, result
      end

      app.get '/favorite_designers' do
        callback = params.delete('callback') # jsonp
        result = UserController.call(:favorite_designers, [params['user_id'].to_i])
        return_response callback, result
      end

      app.get '/user_twitters' do
        callback = params.delete('callback')
        result = UserController.call(:get_user_twitters, [params['user_id'].to_i, params['page_size'].to_i, params['current_page'].to_i])
        return_response callback, result
      end

      app.post '/user_delete_twitter' do
        callback = params.delete('callback')
        result = UserController.call(:delete_twitter, [params['user_id'].to_i, params['twitter_id'].to_i])
        return_response callback, result
      end

      app.get '/account' do
        callback = params.delete('callback')
        result = UserController.call(:get_account, [params['user_id'].to_i])
        return_response callback, result
      end

      app.get '/account_logs' do
        callback = params.delete('callback')
        result = UserController.call(:get_account_logs, [params['user_id'].to_i, params['page_size'].to_i, params['current_page'].to_i])
        return_response callback, result
      end

      app.post '/recharge' do
        callback = params.delete('callback')
        result = UserController.call(:recharge, [params['user_id'].to_i, params['balance'].to_i, params['channel']])
        return_response callback, result
      end

      app.post '/donate_stars' do
        callback = params.delete('callback')
        result = UserController.call(:donate_stars, [params['user_id'].to_i, params['to_user_id'].to_i, params['balance'].to_i])
        return_response callback, result
      end

      app.get '/messages' do
        callback = params.delete('callback')
        result = UserController.call(:messages, [params['user_id'].to_i])
        return_response callback, result
      end

      app.post '/del_message' do
        callback = params.delete('callback')
        result = UserController.call(:delete_message, [params['message_id'].to_i])
        return_response callback, result
      end

      app.post '/modify_avatar' do
        callback = params.delete('callback')
        result = UserController.call(:modify_avatar, [params['user_id'].to_i, params['image_path']])
        return_response callback, result
      end

      app.post '/modify_name' do
        callback = params.delete('callback')
        result = UserController.call(:modify_name, [params['user_id'].to_i, params['new_name']])
        return_response callback, result
      end

      app.post '/modify_gender' do
        callback = params.delete('callback')
        result = UserController.call(:modify_gender, [params['user_id'].to_i, params['new_gender']])
        return_response callback, result
      end

      app.post '/add_call_log' do
        callback = params.delete('callback')
        result = UserController.call(:add_call_log, [params['user_id'].to_i, params['designer_id'].to_i])
        return_response callback, result
      end
    end
  end
end



