#encoding:utf-8
require "pay/wechat_pay"
require 'controllers/pay_controller'

class WechatPayController < PayController
  PAY_CHANNEL = "WX"

  def initialize
    super
    @wechat_pay = Pay::WechatPay.new
  end

  def generate_pay_req params
    user_id = params.delete("user_id")
    count = params.delete("count")
    product = params.delete("product")
    total_fee = count.to_i * 100 * STAR_PRICE if product == 'STAR'
    total_fee = count.to_i * 100 * VIP_PRICE if product == 'VIP'
    params['total_fee'] = total_fee || params['total_fee']
    order = @user_service.create_order user_id, product, count, params['total_fee'].to_f/100
    @user_service.update_order order, "result", "订单创建成功"
    out_trade_no = @wechat_pay.generate_out_trade_no PAY_CHANNEL
    payment_log = @user_service.create_payment_log order.id, out_trade_no, PAY_CHANNEL
    @user_service.update_payment_log(payment_log, "subject", params['body'])
    prepay_order = @wechat_pay.create_prepay_order params, out_trade_no

    unless prepay_order.nil?
      @user_service.update_payment_log(payment_log, "seller_id", prepay_order['mch_id'])
      data = @wechat_pay.generate_pay_req prepay_order['prepay_id']
      success.merge({data: data.merge({out_trade_no: out_trade_no})})
    else
      error("create prepay order for wechat failed wiht params #{params}.")
    end
  end

  def notify params
    if @wechat_pay.verify? params
      out_trade_no = params["out_trade_no"]
      result_code = params["result_code"]
      payment_log = @user_service.get_payment_log out_trade_no
      order = payment_log.order
      if order.status == CREATED
        @user_service.update_payment_log(payment_log, "trade_status", params['result_code'])
        @user_service.update_payment_log(payment_log, "trade_no", params['transaction_id'])
        if result_code.upcase == SUCCESS
          @user_service.update_order order, "status", PAID
          @user_service.update_order order, "result", "买家支付成功"
          deliver_order order, PAY_CHANNEL
        else
          @user_service.update_order order, "status", UNPAY
          @user_service.update_order order, "result", "买家支付失败"
        end
      end
      {return_code: SUCCESS, return_msg: "OK"}
    else
      {return_code: FAIL, return_msg: "签名失效"}
    end
  end
end