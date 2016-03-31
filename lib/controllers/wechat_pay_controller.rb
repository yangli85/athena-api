#encoding:utf-8
require "pay/wechat_pay"
require 'controllers/base_controller'
require 'pandora/services/user_service'

class WechatPayController < BaseController
  PAY_CHANNEL = "WX"

  def initialize
    @user_service = Pandora::Services::UserService.new
    @wechat_pay = Pay::WechatPay.new
  end

  def generate_pay_req params
    user_id = params.delete("user_id")
    out_trade_no = @wechat_pay.generate_out_trade_no PAY_CHANNEL
    payment_log = @user_service.create_payment_log user_id, out_trade_no, PAY_CHANNEL
    @user_service.update_payment_log(payment_log, "subject", params['body'])
    @user_service.update_payment_log(payment_log, "total_fee", params['total_fee'].to_i/100)
    prepay_order = @wechat_pay.create_prepay_order params, out_trade_no
    unless prepay_order.nil?
      @user_service.update_payment_log(payment_log, "trade_no", prepay_order['prepay_id'])
      @user_service.update_payment_log(payment_log, "seller_id", prepay_order['mch_id'])
      data = @wechat_pay.generate_pay_req prepay_order['prepay_id']
      success.merge({data: data})
    else
      error("create prepay order for wechat failed.")
    end
  end

  def notify params
    if @wechat_pay.verify? params
      out_trade_no = params["out_trade_no"]
      payment_log = @user_service.get_payment_log out_trade_no
      @user_service.update_payment_log(payment_log, "trade_status", params['result_code'])
      {return_code: "SUCCESS", return_msg: "OK"}
    else
      {return_code: "FAIL", return_msg: "签名实效"}
    end
  end
end