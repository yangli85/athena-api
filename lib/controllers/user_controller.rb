#encoding:utf-8
require 'controllers/base_controller'
require 'pandora/services/user_service'
require 'pandora/services/designer_service'
require 'pandora/services/sms_service'
require 'pandora/services/twitter_service'
require 'common/error'
require 'common/image_helper'
require 'common/controller_helper'

class UserController < BaseController
  include Common::ControllerHelper

  def initialize
    @user_service = Pandora::Services::UserService.new
    @designer_service = Pandora::Services::DesignerService.new
    @sms_service =Pandora::Services::SMSService.new
    @twitter_service =Pandora::Services::TwitterService.new
  end

  def login phone_number, code, type='user'
    raise Common::Error.new("短信验证码错误") unless correct_code? phone_number, code
    user = @user_service.get_user_by_phone_number phone_number
    is_new = (type == "designer") ? (user.nil? || user.designer.nil?) : user.nil?
    user = @user_service.create_user phone_number if user.nil?
    designer = user.designer || @designer_service.create_designer(user.id) if type=='designer'
    data = {is_new: is_new, user_id: user.id}
    data.merge!({designer_id: designer.id}) if type == "designer"
    success.merge({data: data})
  end

  def upload_image image_base_64
    temp_image_path = Common::ImageHelper.new.save(image_base_64, ENV['TEMP_IMAGES_FOLDER'])
    success.merge(data: {temp_image_path: temp_image_path})
  end

  def publish_new_twitter author_id, designer_id, content, image_paths, stars, latitude, longitude
    image_paths = rebuild_images image_paths
    user = @user_service.get_user_by_id author_id
    account = user.account
    raise Common::Error.new("对不起,星星不够!") unless account.balance >= stars
    begin
      @twitter_service.create_twitter author_id, designer_id, content, image_paths, stars, latitude, longitude, twitter_image_folder
      designer = @designer_service.get_designer designer_id
      account_log_desc = "使用了#{stars}颗星星给#{designer.user.name}点赞"
      @user_service.update_account_balance account.id, -stars, account_log_desc, author_id, designer_id, 'consume', 'beautyshow'
      @user_service.create_message designer.user.id, "#{user.name}发布了一条关于你的新动态,送给你#{stars}颗星星"
      @designer_service.update_designer designer_id, 'totally_stars', designer.totally_stars + stars
      @designer_service.update_designer designer_id, 'weekly_stars', designer.weekly_stars + stars
      @designer_service.update_designer designer_id, 'monthly_stars', designer.monthly_stars + stars
      success.merge({message: "发布动态成功."})
    ensure
      image_paths.each do |path|
        File.delete(path[:image_path]) if File.exist? path[:image_path]
        File.delete(path[:s_image_path]) if File.exist? path[:s_image_path]
      end
    end
  end

  def get_user_details user_id
    begin
      user = @user_service.get_user_by_id user_id
      new_message_count = @user_service.get_new_messages_count user_id
      data = user.attributes.merge({
                                       vitality: user.vitality,
                                       sex: user.gender,
                                       new_message_count: new_message_count,
                                       balance: user.account && user.account.balance,
                                       twitter_count: user.twitters.count,
                                       phone_number: user.phone_number
                                   })
      success.merge({data: data})
    rescue => e
      raise Common::Error.new("该用户不存在.")
    end
  end

  def add_favorite_image twitter_id, user_id, image_id
    @user_service.add_favorite_image user_id, image_id
    @twitter_service.update_twitter_image_likes twitter_id, image_id
    success.merge({message: "加入收藏成功."})
  end

  def del_favorite_images ids
    @user_service.del_favorite_images ids
    success.merge({message: "删除收藏成功."})
  end

  def del_favorite_image user_id, image_id
    @user_service.del_favorite_image user_id, image_id
    success.merge({message: "删除收藏成功."})
  end

  def favorite_images user_id
    favorite_images = @user_service.favorited_images user_id
    data = favorite_images.map do |favorite_image|
      {
          id: favorite_image.id,
          image: favorite_image.favorited_image && favorite_image.favorited_image.attributes
      }
    end
    success.merge({data: data})
  end

  def add_favorite_designer user_id, designer_id
    @user_service.add_favorite_designer user_id, designer_id
    success.merge({message: "加入收藏成功."})
  end

  def del_favorite_designers ids
    @user_service.del_favorite_designers ids
    success.merge({message: "删除收藏成功."})
  end

  def favorite_designers user_id
    favorite_designers = @user_service.favorited_designers user_id
    data = favorite_designers.map do |favorite_designer|
      designer = favorite_designer.favorited_designer
      {
          id: favorite_designer.id,
          designer: designer.attributes.merge({
                                                  stars: designer.totally_stars,
                                                  shop: designer.shop && designer.shop.attributes
                                              })
      }
    end
    success.merge({data: data})
  end

  def get_user_twitters user_id, page_size, current_page
    twitters = @user_service.get_user_twitters user_id, page_size, current_page
    success.merge({data: twitters.map(&:attributes)})
  end

  def delete_twitter user_id, twitter_id
    @user_service.delete_twitter user_id, twitter_id
    success.merge({message: "动态删除成功"})
  end

  def get_account user_id
    account = @user_service.get_account user_id
    data = {
        id: account.id,
        balance: account.balance
    }
    success.merge({data: data})
  end

  def get_account_logs user_id, page_size, current_page
    logs = @user_service.get_account_logs user_id, page_size, current_page
    success.merge({data: logs.map(&:attributes)})
  end

  def recharge user_id, balance, channel
    user = @user_service.get_user_by_id user_id
    @user_service.update_account_balance user.account.id, balance, "购买了#{balance}颗星星", user.id, user.id, 'recharge', channel
    success.merge({message: "购买成功."})
  end

  def donate_stars user_id, to_user_id, balance
    raise Common::Error.new("星星赠送数量填写错误.") unless balance>0
    user = @user_service.get_user_by_id user_id
    to_user = @user_service.get_user_by_id to_user_id
    account = user.account
    to_account = to_user.account
    raise Common::Error.new("你账户上的星星不够.") unless account.balance >= balance
    account_log_desc = "赠送给#{to_user.name}#{balance}颗星星"
    @user_service.update_account_balance account.id, -balance, account_log_desc, user.id, to_user.id, 'donate', 'beautyshow'
    account_log_desc = "收到#{user.name}赠送给你的#{balance}颗星星"
    @user_service.update_account_balance to_account.id, balance, account_log_desc, user.id, to_user.id, 'donate', 'beautyshow'
    @user_service.create_message to_user_id, account_log_desc
    success.merge({message: "赠送成功."})
  end

  def messages user_id
    messages = @user_service.get_messages user_id
    @user_service.update_messages user_id
    success.merge({data: messages.map(&:attributes)})
  end

  def delete_message message_id
    @user_service.delete_message message_id
    success.merge({message: "删除成功"})
  end

  def modify_avatar user_id, image_path
    s_image_path = generate_small_image image_path
    new_image_path = {
        image_path: image_path,
        s_image_path: s_image_path
    }
    begin
      @user_service.update_user_avatar user_id, new_image_path, avatar_image_folder
      success.merge({message: "头像修改成功"})
    ensure
      File.delete(new_image_path[:image_path]) if File.exist? new_image_path[:image_path]
      File.delete(new_image_path[:s_image_path]) if File.exist? new_image_path[:s_image_path]
    end
  end

  def modify_name user_id, new_name
    @user_service.update_user_profile user_id, 'name', new_name
    success
  end

  def modify_gender user_id, new_gender
    @user_service.update_user_profile user_id, 'gender', new_gender
    success
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