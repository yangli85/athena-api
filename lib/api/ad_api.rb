require 'controllers/ad_controller'
module API
  class AdAPI
    def self.registered(app)
      app.get '/ad_images' do
        callback = params.delete('callback') # jsonp
        result = AdController.call(:get_ad_images, [params['category']])
        return_response callback, result
      end
    end
  end
end




