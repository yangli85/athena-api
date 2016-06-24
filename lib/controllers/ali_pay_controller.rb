#encoding:utf-8
require "pay/ali_pay"
require 'controllers/pay_controller'

class AliPayController < PayController
  PAY_CHANNEL = "ALI"

  def initialize
    super
    @ali_pay = Pay::AliPay.new
  end

  def generate_pay_req params
    user_id = params.delete("user_id")
    count = params.delete("count")
    product = params.delete("product")
    total_fee = count * STAR_PRICE if product == 'STAR'
    total_fee = count * VIP_PRICE if product == 'VIP'
    params['total_fee'] = total_fee || params['total_fee']
    order = @user_service.create_order user_id, product, count, params['total_fee']
    @user_service.update_order order, "result", "订单创建成功"
    out_trade_no = @ali_pay.generate_out_trade_no PAY_CHANNEL
    payment_log = @user_service.create_payment_log order.id, out_trade_no, PAY_CHANNEL
    pay_info = @ali_pay.generate_pay_req params, out_trade_no
    @user_service.update_payment_log(payment_log, "subject", pay_info['subject'])
    @user_service.update_payment_log(payment_log, "seller_id", pay_info['partner'])
    success.merge(
        {
            data:
                {
                    pay_info: pay_info,
                    out_trade_no: out_trade_no
                }
        }
    )
  end

  def notify params
    if @ali_pay.verify? params
      out_trade_no = params["out_trade_no"]
      payment_log = @user_service.get_payment_log out_trade_no
      order = payment_log.order
      if order.status == CREATED
        @user_service.update_payment_log(payment_log, "seller_email", params['seller_email'])
        @user_service.update_payment_log(payment_log, "buyer_id", params['buyer_id'])
        @user_service.update_payment_log(payment_log, "buyer_email", params['buyer_email'])
        @user_service.update_payment_log(payment_log, "trade_no", params['trade_no'])
        if params['trade_status'] == TRADE_FINISHED || params['trade_status'] == TRADE_SUCCESS
          @user_service.update_payment_log(payment_log, "trade_status", SUCCESS)
          @user_service.update_order order, "status", PAID
          @user_service.update_order order, "result", "买家支付成功"
          deliver_order order, PAY_CHANNEL
        elsif params['trade_status'] != WAIT_BUYER_PAY
          @user_service.update_payment_log(payment_log, "trade_status", params['trade_status'])
          @user_service.update_order order, "status", UNPAY
          @user_service.update_order order, "result", "买家支付失败"
        end
      end
      SUCCESS.downcase
    else
      FAIL
    end
  end
end