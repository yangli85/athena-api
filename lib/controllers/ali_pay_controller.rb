#encoding:utf-8
require "pay/ali_pay"
require 'controllers/base_controller'
require 'pandora/services/user_service'

class AliPayController < BaseController
  PAY_CHANNEL = "ALI"

  def initialize
    @user_service = Pandora::Services::UserService.new
    @ali_pay = Pay::AliPay.new
  end

  def generate_pay_req params
    user_id = params.delete("user_id")
    out_trade_no = @ali_pay.generate_out_trade_no PAY_CHANNEL
    payment_log = @user_service.create_payment_log user_id, out_trade_no, PAY_CHANNEL
    data = @ali_pay.generate_pay_req params, out_trade_no
    @user_service.update_payment_log(payment_log, "subject", data['subject'])
    @user_service.update_payment_log(payment_log, "seller_id", data['partner'])
    @user_service.update_payment_log(payment_log, "total_fee", data['total_fee'])
    success.merge({data: data})
  end

  def notify params
    if @ali_pay.verify? params
      out_trade_no = params["out_trade_no"]
      payment_log = @user_service.get_payment_log
      @user_service.update_payment_log(payment_log, "seller_email", params['seller_email'])
      @user_service.update_payment_log(payment_log, "buyer_id", params['buyer_id'])
      @user_service.update_payment_log(payment_log, "buyer_email", params['buyer_email'])
      @user_service.update_payment_log(payment_log, "trade_no", params['trade_no'])
      if params['trade_status'] == "TRADE_FINISHED" || params['trade_status'] == "TRADE_SUCCESS"
        @user_service.update_payment_log(payment_log, "trade_status", "SUCCESS")
      else
        @user_service.update_payment_log(payment_log, "trade_status", params['trade_status'])
      end
      "success"
    else
      "fail"
    end
  end
end