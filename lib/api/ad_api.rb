require 'controllers/ad_controller'

class AdAPI
  def self.registered(app)
    app.get '/ad_images' do
      callback = params.delete('callback') # jsonp
      result = AdController.call(:get_ad_images, [params['catogory']])
      return_response callback, result
    end
  end
end



