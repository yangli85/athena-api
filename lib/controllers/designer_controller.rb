#encoding:utf-8
require 'pandora/services/designer_service'
require 'pandora/services/shop_service'
require 'pandora/services/user_service'
require 'pandora/services/twitter_service'
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
    @twitter_service = Pandora::Services::TwitterService.new
    @shop_service = Pandora::Services::ShopService.new
  end

  def get_vicinal_designers longitude, latitude, page_size, current_page, range, order_by
    ordered_shops =@shop_service.get_vicinal_shops longitude, latitude, range
    designers = []
    ordered_shops.each do |a_shop|
      shop = @shop_service.get_shop a_shop.id
      shop_designers = shop.designers.vip.order("#{order_by} desc").map do |designer|
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
                                                     is_vip: designer.is_vip,
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
                                           vitae_count: designer.vitae.count,
                                           is_vip: designer.is_vip,
                                           expired_at: designer.expired_at

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

  def designer_customers designer_id, page_size, current_page
    customers = @designer_service.get_customers designer_id, page_size, current_page
    data = customers.map do |customer|
      customer.attributes.merge({phone_number: customer.phone_number})
    end
    success.merge({data: data})
  end

  def search_customers designer_id, page_size, current_page, query
    customers = @designer_service.search_customers designer_id, query, page_size, current_page
    data = customers.map do |customer|
      customer.attributes.merge({phone_number: customer.phone_number})
    end
    success.merge({data: data})
  end


  def update_new_shop name, address, latitude, longitude, designer_id, province, city
    designer = @designer_service.get_designer designer_id
    shop = designer.shop
    unless is_same_shop? designer.shop, name, latitude, longitude
      shop = @shop_service.create_shop name, address, latitude, longitude, province, city
      @designer_service.update_shop designer_id, shop.id
    end
    success.merge({message: "修改店铺成功"})
  end

  def update_shop designer_id, shop_id
    @designer_service.update_shop designer_id, shop_id
    success.merge({message: "修改店铺成功"})
  end

  def search_shops name
    shops = @shop_service.search_shops_by_name name
    success.merge({data: shops.map(&:attributes)})
  end

  def create_vita desc, image_paths, designer_id
    image_paths = rebuild_images image_paths
    designer = @designer_service.get_designer designer_id
    @designer_service.create_vita designer.id, image_paths, desc, vita_image_folder
    designer.users.each do |user|
      @user_service.create_message user.id, "#{designer.user.name}更新了自己的个人空间,快去看看!"
    end
    success.merge({message: "添加成功"})
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
    @designer_service.update_designer designer_id, "activated", true unless designer.activated
    success.merge({message: "缴费成功"})
  end

  def shop_details id
    shop = @shop_service.get_shop id
    data = shop.attributes.merge({
                                     images: shop.images.map(&:attributes),
                                     desc: shop.desc,
                                     scale: shop.scale,
                                     category: shop.category
                                 })
    success.merge({data: data})
  end

  def get_commend_designers
    new_designer = @designer_service.get_new_designer
    top1_designer = @designer_service.get_top1_designer "weekly_stars"
    new_twitter = @twitter_service.get_latest_twitter
    new_twitter_designer = new_twitter && new_twitter.designer
    data = {
        new_designer: new_designer && new_designer.attributes.merge({
                                                                        shop: new_designer.shop && new_designer.shop.attributes,
                                                                    }),
        top1_designer: top1_designer && top1_designer.attributes.merge({
                                                                           shop: top1_designer.shop && top1_designer.shop.attributes,
                                                                       }),
        new_twitter_designer: new_twitter_designer && new_twitter_designer.attributes.merge({
                                                                                                shop: new_twitter_designer.shop && new_twitter_designer.shop.attributes,
                                                                                            })
    }
    success.merge({data: data})
  end
end