require 'pandora/services/twitter_service'
require 'controllers/base_controller'

class TwitterController < BaseController
  def initialize
    @twitter_service = Pandora::Services::TwitterService.new
  end

  def get_ordered_twitter_images page_size, current_page, order_by
    twitter_images = @twitter_service.get_ordered_twitter_images page_size, current_page, order_by
    success.merge({data: twitter_images.map(&:attributes)})
  end

  def get_twitter_images twitter_id
    twitter = @twitter_service.search_twitter_by_id twitter_id
    success.merge({data: twitter && twitter.attributes})
  end

  def get_ordered_twitters page_size, current_page, order_by
    twitters = @twitter_service.get_ordered_twitters page_size, current_page, order_by
    success.merge({data: twitters.map(&:attributes)})
  end

  def search_twitter_by_id twitter_id
    twitter = @twitter_service.search_twitter_by_id twitter_id
    success.merge({data: twitter && twitter.attributes})
  end

end