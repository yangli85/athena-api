require 'controllers/twitter_controller'

class TwitterAPI
  def self.registered(app)
    app.get '/twitter_images' do
      callback = params.delete('callback') # jsonp
      result = TwitterController.call(:get_ordered_twitter_images, [params['page_size'], params['current_page'], params['order_by']])
      return_response callback, result
    end

    app.get '/twitter_images_view' do
      callback = params.delete('callback') # jsonp
      result = TwitterController.call(:get_twitter_images, [params['twitter_id']])
      return_response callback, result
    end

    app.get '/twitters' do
      callback = params.delete('callback') # jsonp
      result = TwitterController.call(:get_ordered_twitters, [params['page_size'], params['current_page'], params['order_by']])
      return_response callback, result
    end

    app.get '/search_twitter' do
      callback = params.delete('callback')
      result = TwitterController.call(:search_twitter_by_id, [params['twitter_id']])
      return_response callback, result
    end
  end
end



