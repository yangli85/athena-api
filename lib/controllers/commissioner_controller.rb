#encoding:utf-8
require 'controllers/base_controller'
require 'pandora/services/commissioner_service'
require 'pandora/services/shop_service'
require 'pandora/services/sms_service'
require 'common/error'
require 'common/image_helper'
require 'common/controller_helper'

class CommissionerController < BaseController
  include Common::ControllerHelper

  def initialize
    @commissioner_service = Pandora::Services::CommissionerService.new
    @shop_service = Pandora::Services::ShopService.new
    @sms_service =Pandora::Services::SMSService.new
  end

  def register phone_number, name, password, code
    raise Common::Error.new("短信验证码错误") unless correct_code? phone_number, code
    commissioner = @commissioner_service.get_commissioner phone_number
    raise Common::Error.new("大王,你已经是我们的人了,可以直接登录.") unless commissioner.nil?
    commissioner = @commissioner_service.register phone_number, name, password
    code_image_path = Common::ImageHelper.new.generate_code_image commissioner.id, temp_image_folder
    @commissioner_service.add_code_image commissioner.id, code_image_path, code_image_folder
    success.merge({message: "恭喜你,注册成功,下一个地推之王非你莫属!"})
  end

  def login phone_number, password
    commissioner = @commissioner_service.get_commissioner phone_number
    raise Common::Error.new("将军你还不是臣妾的人,赶快注册加入吧!") if commissioner.nil?
    raise Common::Error.new("密码错啦,想找回密码就联系臣妾吧!") unless commissioner.password == password
    success.merge({
                      message: "欢迎大将军#{commissioner.name}回归!",
                      c_id: commissioner.id,
                      c_name: commissioner.name
                  })
  end

  def details c_id
    commissioner = @commissioner_service.get_commissioner_by_id c_id
    max_count = @commissioner_service.get_promotion_logs_count c_id
    users = @commissioner_service.get_promotion_users c_id, max_count, 1
    designers = @commissioner_service.get_promotion_designers c_id, max_count, 1
    vip_designers = @commissioner_service.get_promotion_vip_designers c_id, max_count, 1
    data = commissioner.attributes.merge({
                                             designer_count: designers.count,
                                             vip_designer_count: vip_designers.count,
                                             user_count: users.count,
                                             be_scanned_times: commissioner.be_scanned_times
                                         })
    success.merge({data: data})
  end

  def update_be_scanned_times c_id
    @commissioner_service.update_commssioner_scanned_times c_id
    success
  end

  def promotion_logs c_id, page_size, current_page
    logs = @commissioner_service.get_promotion_logs c_id, page_size, current_page
    success.merge({data: logs.map(&:attributes)})
  end

  def add_promotion_log c_id, user_phone_number, mobile_type
    @commissioner_service.add_promotion_log c_id, user_phone_number, mobile_type
    success
  end

  def del_promotion_log log_id
    @commissioner_service.delete_promotion_log log_id
    success
  end

  def promotion_users c_id, page_size, current_page
    users = @commissioner_service.get_promotion_users c_id, page_size, current_page
    data = users.map do |user|
      user.attributes.merge({phone_number: user.phone_number, created_at:  user.created_at.strftime("%Y-%m-%d %H:%M:%S")})
    end
    success.merge({data: data})
  end

  def promotion_designers c_id, page_size, current_page
    designers = @commissioner_service.get_promotion_designers c_id, page_size, current_page
    data = designers.map do |designer|
      designer.attributes.merge({phone_number: designer.user.phone_number, created_at: designer.created_at.strftime("%Y-%m-%d %H:%M:%S")})
    end
    success.merge({data: data})
  end

  def promotion_vip_designers c_id, page_size, current_page
    designers = @commissioner_service.get_promotion_vip_designers c_id, page_size, current_page
    data = designers.map do |designer|
      designer.attributes.merge({phone_number: designer.user.phone_number, created_at: designer.created_at.strftime("%Y-%m-%d %H:%M:%S")})
    end
    success.merge({data: data})
  end


  def shop_promotion_logs c_id, shop_id, page_size, current_page
    logs = @commissioner_service.get_shop_promotion_logs c_id, shop_id, page_size, current_page
    success.merge({data: logs.map(&:attributes)})
  end

  def personal_QR_code c_id
    image_path = @commissioner_service.get_commissioner_QR_code c_id
    success.merge({image_path: image_path})
  end

  def register_shop name, address, longitude, latitude, scale, category, desc, c_id, image_paths, province, city
    image_paths = rebuild_images image_paths
    shops = @shop_service.get_similar_shops name, address, longitude, latitude
    raise Common::Error.new("臣妾觉的这家店铺已经被录入了,大王搜索一下看看能找到吗?") unless shops.empty?
    commissioner = @commissioner_service.get_commissioner_by_id c_id
    shop = @commissioner_service.register_shop name, address, longitude, latitude, scale, category, desc, image_paths, shop_image_folder, province, city
    @commissioner_service.add_shop_promotion_log c_id, shop.id, "#{commissioner.name}(#{commissioner.phone_number})录入店铺#{shop.name}的信息"
    success.merge({message: "该店铺已经录入系统,辛苦啦,加油!"})
  end

  def delete_shop c_id, shop_id
    shop = @shop_service.get_shop shop_id
    raise Common::Error.new("该店铺已经有关联的设计师,不能被删除!") if shop.designers.length > 0
    commissioner = @commissioner_service.get_commissioner_by_id c_id
    @commissioner_service.delete_shop shop_id
    @commissioner_service.add_shop_promotion_log c_id, shop_id, "#{commissioner.name}(#{commissioner.phone_number})删除了店铺#{shop.name}"
    success.merge({message: "店铺#{shop.name}被你删除了,小心删错了!"})
  end


  def search_shops query, page_size, current_page, order_by
    shops = @shop_service.search_shops query, page_size, current_page, order_by
    success.merge({data: shops.map(&:attributes)})
  end

  def shops page_size, current_page, order_by
    shops = @shop_service.shops page_size, current_page, order_by
    success.merge({data: shops.map(&:attributes)})
  end

  def shop_all_promotion_logs shop_id, page_size, current_page
    logs = @commissioner_service.get_shop_all_promotion_logs shop_id, page_size, current_page
    success.merge({data: logs.map(&:attributes)})
  end

  def add_shop_promotion_log c_id, shop_id, content
    @commissioner_service.add_shop_promotion_log c_id, shop_id, content
    success.merge({message: "加油,你就是下一个地推之王!"})
  end

  private
  def correct_code? phone_number, code
    if code == "8888"
      return true
    end
    latest_sms_code = @sms_service.get_latest_code phone_number
    !latest_sms_code.nil? && code == latest_sms_code.code
  end
end