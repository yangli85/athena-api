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
          image: ad_image.image && ad_image.image.attributes,
          event: ad_image.event,
          args: ad_image.args
      }
    end
    success.merge({data: data})
  end

  def get_latest_popup_ad
    popup_ad = @ad_service.get_latest_popup_ad
    success.merge({data: popup_ad.attributes})
  end
end