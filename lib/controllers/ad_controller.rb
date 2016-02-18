require 'pandora/services/ad_service'
require 'controllers/base_controller'

class AdController < BaseController
  def initialize
    @ad_service = Pandora::Services::AdService.new
  end

  def get_ad_images category
    ad_images = @ad_service.get_ad_images category
    data = ad_images.map do |ad_image|
      {
          image: ad_image.image.url,
          event: ad_image.event,
          args: ad_image.args
      }
    end
    success.merge({data: data})
  end
end