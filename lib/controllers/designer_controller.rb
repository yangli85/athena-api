#encoding:utf-8
require 'pandora/services/designer_service'
require 'pandora/services/shop_service'
require 'pandora/services/user_service'
require 'controllers/base_controller'
require 'common/error'
require 'common/image_helper'
require 'common/controller_helper'

class DesignerController < BaseController
  include Common::ControllerHelper

  def initialize
    @shop_service = Pandora::Services::ShopService.new
    @designer_service = Pandora::Services::DesignerService.new
    @user_service = Pandora::Services::UserService.new
    @shop_service = Pandora::Services::ShopService.new
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
    twitters = @designer_service.get_designer_twitters designer_id, page_size, current_page
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
    success.merge({data: {
        rank: rank
    }})
  end

  def get_designer_details designer_id
    begin
      designer = @designer_service.get_designer designer_id
      user = designer.user
      new_message_count = @user_service.get_new_messages_count user.id
      data = designer.attributes.merge({
                                           vitality: designer.user.vitality,
                                           gender: designer.user.gender,
                                           new_message: new_message_count,
                                           balance: user.account && user.account.balance,
                                           twitters: designer.twitters.count,
                                           phone_number: user.phone_number,
                                           shop: designer.shop && designer.shop.attributes,
                                           vitae_count: designer.vitae.count
                                       })
      success.merge({data: data})
    rescue => e
      raise Common::Error.new("设计师不存在.")
    end
  end

  def get_designer_twitters designer_id, page_size, current_page
    twitters = @designer_service.get_designer_twitters designer_id, page_size, current_page
    success.merge({data: twitters.map(&:attributes)})
  end

  def delete_twitter designer_id, twitter_id
    @designer_service.delete_twitter designer_id, twitter_id
    success.merge({message: "动态删除成功"})
  end

  def designer_latest_customers designer_id
    customers = @designer_service.get_customers designer_id
    data = customers.map do |customer|
      customer.attributes.merge({phone_number: customer.phone_number})
    end
    success.merge({data: data})
  end

  def update_new_shop name, address, latitude, longtitude, designer_id
    shop = @shop_service.create_shop name, address, latitude, longtitude
    @designer_service.update_shop designer_id, shop.id
    success.merge({message: "修改店铺成功"})
  end

  def update_shop designer_id, shop_id
    @designer_service.update_shop designer_id, shop_id
    success.merge({message: "修改店铺成功"})
  end

  def search_shops name
    shops = @shop_service.search_shops name
    success.merge({data: shops.map(&:attributes)})
  end

  def create_vita desc, image_paths, designer_id
    image_paths = rebuild_images image_paths
    begin
      @designer_service.create_vita designer_id, image_paths, desc, vita_image_folder
      success.merge({message: "添加成功"})
    ensure
      image_paths.each do |path|
        File.delete(path[:image_path]) if File.exist? path[:image_path]
        File.delete(path[:s_image_path]) if File.exist? path[:s_image_path]
      end
    end
  end

  def delete_vitae vita_ids
    @designer_service.delete_designer_vitae vita_ids
    success.merge({message: "删除成功"})
  end

  def pay_for_vip designer_id
    designer = @designer_service.get_designer designer_id
    expired_at = DateTime.now >> 12
    if designer.is_vip
      expired_at = designer.expired_at.to_datetime >> 12
    end
    @designer_service.update_designer designer_id, "expired_at", expired_at
    @designer_service.update_designer designer_id, "is_vip", true unless designer.is_vip
  end
end