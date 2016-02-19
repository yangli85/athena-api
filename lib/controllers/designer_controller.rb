#encoding:utf-8
require 'pandora/services/designer_service'
require 'pandora/services/shop_service'
require 'controllers/base_controller'
require 'common/error'

class DesignerController < BaseController
  def initialize
    @shop_service = Pandora::Services::ShopService.new
    @designer_service = Pandora::Services::DesignerService.new
  end

  def get_vicinal_designers longtitude, latitude, page_size, current_page, range, order_by
    ordered_shops =@shop_service.get_vicinal_shops longtitude, latitude, range
    designers = []
    ordered_shops.each do |a_shop|
      shop = @shop_service.get_shop a_shop.id
      shop_designers = shop.designers.order("#{order_by} desc").map do |designer|
        designer.attributes.merge({
                                      distance: a_shop.distance,
                                      stars: designer.totally_stars,
                                      shop: shop.attributes
                                  }
        )
      end
      designers.concat shop_designers
    end
    offset = page_size*(current_page-1)
    data = designers[offset, page_size] || []
    success.merge({data: data})
  end

  def get_ordered_designers page_size, current_page, order_by
    designers = @designer_service.get_ordered_designers page_size, current_page, order_by
    data = designers.map do |designer|
      designer.attributes.merge({
                                    stars: designer.send(order_by.to_sym),
                                    shop: designer.shop && designer.shop.attributes
                                })
    end
    success.merge({data: data})
  end

  def get_designer_info designer_id
    designer = @designer_service.get_designer designer_id
    rank = @designer_service.get_designer_rank designer_id, 'totally_stars'
    data = designer && designer.attributes.merge({
                                                     shop: designer.shop && designer.shop.attributes,
                                                     gender: designer.user.gender,
                                                     stars: designer.totally_stars,
                                                     rank: rank,
                                                     phone_number: designer.user.phone_number
                                                 })
    success.merge(data: data)
  end

  def get_designer_works designer_id, page_size, current_page
    twitters = @designer_service.get_designer_twitters designer_id, page_size, current_page, 'created_at'
    data = twitters.map do |twitter|
      twitter.twitter_images.order("likes desc").first.attributes
    end
    success.merge({data: data})
  end

  def get_designer_vitae designer_id, page_size, current_page
    vitae = @designer_service.get_designer_vitae designer_id, page_size, current_page
    success.merge({data: vitae.map(&:attributes)})
  end

  def search_designers page_size, current_page, query
    designers= @designer_service.search_designers page_size, current_page, query
    data = designers.map do |designer|
      designer.attributes.merge({
                                    shop: designer.shop && designer.shop.attributes,
                                    stars: designer.totally_stars
                                })
    end
    success.merge({data: data})
  end

  def get_designer_rank designer_id, order_by
    rank = @designer_service.get_designer_rank designer_id, order_by
    success.merge({data:{
        rank: rank
    }})
  end
end