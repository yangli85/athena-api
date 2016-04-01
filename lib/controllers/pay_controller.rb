#encoding:utf-8
require "pay/wechat_pay"
require 'controllers/base_controller'
require 'pandora/services/user_service'
require 'pandora/services/designer_service'

class PayController < BaseController
  def initialize
    @user_service = Pandora::Services::UserService.new
    @designer_service = Pandora::Services::DesignerService.new
  end

  def get_order_details out_trade_no
    payment_log = @user_service.get_payment_log out_trade_no
    order = payment_log.order
    success.merge({status: order.status, message: order.result, data: order.attributes})
  end

  private
  def recharge user_id, balance, channel
    user = @user_service.get_user_by_id user_id
    @user_service.update_account_balance user.account.id, balance, "购买了#{balance}颗星星", user.id, user.id, 'recharge', channel
    @user_service.update_user_profile user_id, "vitality", user.vitality + balance
  end

  def pay_for_vip user_id, count
    user = @user_service.get_user_by_id user_id
    designer = user.designer
    expired_at = DateTime.now >> (12*count)
    if designer.is_vip
      expired_at = designer.expired_at.to_datetime >> (12*count)
    end
    @designer_service.update_designer designer_id, "expired_at", expired_at
    @designer_service.update_designer designer_id, "is_vip", true unless designer.is_vip
  end

  def deliver_order order, pay_channel
    if order.product == "VIP"
      pay_for_vip order.user_id, order.count
      @user_service.update_order order, "status", SUCCESS
      @user_service.update_order order, "result", "会员续费成功"
    elsif order.product == "STAR"
      recharge order.user_id, order.count, pay_channel
      @user_service.update_order order, "status", SUCCESS
      @user_service.update_order order, "result", "#{order.count}颗星星购买成功"
    else
      @user_service.update_order order, "status", UNKNOW_PRODUCT
      @user_service.update_order order, "result", "产品类别未知"
    end
  end
end