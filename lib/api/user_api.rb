# encoding: UTF-8
class UserAPI
  def self.registered(app)
    app.get '/consumer_details' do
      callback = params.delete('callback') # jsonp
      result = UserController.call(:get_user_details, [params['user_id'])
      return_response callback, result
    end

    app.post '/upload_image' do
      callback = params.delete('callback') # jsonp
      result = UserController.call(:upload_image, [params['image_base64'])
      return_response callback, result
    end

    app.post '/publish_twitter' do
      callback = params.delete('callback') # jsonp
      image_paths = params['image_paths'].split(",")
      args = [params['author_id'], params['designer_id'], params['content'], image_paths, params['stars'], params['latitude'], params['longtitude']]
      result = UserController.call(:publish_new_twitter, args)
      return_response callback, result
    end

    app.post '/add_favorite_image' do
      callback = params.delete('callback') # jsonp
      result = UserController.call(:add_favorite_image, [params['user_id'], params['image_id']])
      return_response callback, result
    end

    app.post '/del_favorite_images' do
      ids = params["ids"].split(',')
      callback = params.delete('callback') # jsonp
      result = UserController.call(:del_favorite_images, [ids]])
      return_response callback, result
    end

    app.get 'favorite_images' do
      callback = params.delete('callback') # jsonp
      result = UserController.call(:favorite_images, [params['user_id']])
      return_response callback, result
    end

    app.post '/add_favorite_designer' do
      callback = params.delete('callback') # jsonp
      result = UserController.call(:add_favorite_designer, [params['user_id'], params['designer_id']])
      return_response callback, result
    end

    app.post '/del_favorite_designers' do
      ids = params["ids"].split(',')
      callback = params.delete('callback') # jsonp
      result = UserController.call(:del_favorite_designers, [ids]])
      return_response callback, result
    end

    app.get 'favorite_designers' do
      callback = params.delete('callback') # jsonp
      result = UserController.call(:favorite_designers, [params['user_id']])
      return_response callback, result
    end

    app.post 'delete_twitters' do
      user_id = params['user_id']
      twitter_id = params['twitter_id']
      callback = params.delete('callback') # jsonp
      result = {
          result: 'success'
      }
      return_response callback, result
    end

    app.get '/user_twitters' do
      callback = params.delete('callback')
      result = UserController.call(:get_user_twitters, [params['user_id'], params['page_size'], params['current_page']])
      return_response callback, result
    end

    app.get '/user_delete_twitter' do
      callback = params.delete('callback')
      result = UserController.call(:delete_twitter, [params['user_id'], params['twitter_id']])
      return_response callback, result
    end

    app.get '/account' do
      callback = params.delete('callback')
      result = UserController.call(:get_account, [params['user_id']])
      return_response callback, result
    end

    app.get '/account_logs' do
      callback = params.delete('callback')
      result = UserController.call(:get_account_logs, [params['user_id'], params['page_size'], params['current_page']])
      return_response callback, result
    end

    app.post '/recharge' do
      callback = params.delete('callback')
      result = UserController.call(:recharge, [params['user_id'], params['balance'], params['channel']])
      return_response callback, result
    end

    app.post '/donate_stars' do
      callback = params.delete('callback')
      result = UserController.call(:donate_stars, [params['user_id'], params['to_user_id'], params['balance']])
      return_response callback, result
    end

    app.get '/messages' do
      callback = params.delete('callback')
      result = UserController.call(:messages, [params['user_id']])
      return_response callback, result
    end

    app.post '/del_message' do
      callback = params.delete('callback')
      result = UserController.call(:delete_message, [params['message_id']])
      return_response callback, result
    end

    app.post '/modify_avatar' do
      callback = params.delete('callback')
      result = UserController.call(:modify_avatar, [params['user_id'],params['image_path']])
      return_response callback, result
    end

    app.post '/modify_name' do
      callback = params.delete('callback')
      result = UserController.call(:modify_name, [params['user_id'],params['new_name']])
      return_response callback, result
    end

    app.post '/modify_gender' do
      callback = params.delete('callback')
      result = UserController.call(:modify_gender, [params['user_id'],params['new_gender']])
      return_response callback, result
    end

    app.post 'del_vitae' do
      designer_id = params['designer_id']
      vita_ids = prams['vita_ids']
      callback = params.delete('callback') # jsonp
      result = {
          result: 'success'
      }
      return_response callback, result
    end

    app.post 'add_vitae' do
      designer_id = params['designer_id']
      vitae = params[vitae]
      result = {
          result: 'success'
      }
      return_response callback, result
    end
  end
end



