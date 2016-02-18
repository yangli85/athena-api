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

    app.post '/add_twitter' do
      authoer_id = params['author_id']
      designer_id = params['designer_id']
      context = params['context']
      stars = params['stars']
      latitude = params['latitude']
      longtitude = params['longtitude']
      images = params['images']
      twitter_id = 1
      images.each do |image|
        File.open("images/1.jpg", "rb") do |file|
          file.write(image.read)
        end
      end
      callback = params.delete('callback') # jsonp
      result = {
          result: 'success'
      }
      return_response callback, result
    end
  end
end



