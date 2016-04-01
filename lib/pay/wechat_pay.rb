require 'rest_client'
require 'active_support/core_ext/hash/conversions'
require "pay/utils"
require 'pay/wechat_pay_result'
require 'common/logging'

module Pay
  class WechatPay
    include Common::Logging
    include Pay::Utils

    GATEWAY_URL = 'https://api.mch.weixin.qq.com'
    PAY_CHANNEL = "WX"
    CREATE_PREPAY_ORDER_REQUIRED_FIELDS = ['appid', 'mch_id', 'nonce_str', 'body', 'out_trade_no', 'total_fee', 'spbill_create_ip', 'notify_url', 'trade_type']
    GENERATE_APP_PAY_REQ_REQUIRED_FIELDS =['appid', 'partnerid', 'prepayid', 'noncestr', 'package', 'noncestr', 'timestamp']

    def initialize
      @app_id = ENV['WX_APP_ID']
      @key = ENV['WX_API_KEY']
      @mch_id = ENV['WX_MCH_ID']
    end

    def generate_pay_req prepay_id
      params = {
          appid: @app_id,
          partnerid: @mch_id,
          prepayid: prepay_id,
          package: "Sign=WXPay",
          noncestr: SecureRandom.uuid.tr('-', ''),
          timestamp: Time.now.to_i.to_s
      }
      check_required_options(params, GENERATE_APP_PAY_REQ_REQUIRED_FIELDS)
      params.merge(
          {
              sign: generate_sign(params, @key)
          }
      )
    end

    def create_prepay_order params, out_trade_no
      params = change_key_to_sym params
      params.merge!(
          {
              appid: @app_id,
              mch_id: @mch_id,
              out_trade_no: out_trade_no,
              nonce_str: SecureRandom.uuid.tr('-', ''),
          }
      )
      check_required_options(params, CREATE_PREPAY_ORDER_REQUIRED_FIELDS)
      params.merge!(
          {
              sign: generate_sign(params, @key)
          }
      )
      invoke_remote "#{GATEWAY_URL}/pay/unifiedorder", hash_to_xml(params)
    end

    def verify? params
      verify_sign? params, @key
    end

    def hash_to_xml params
      "<xml>#{params.map { |k, v| "<#{k}>#{v}</#{k}>" }.join}</xml>"
    end

    private

    def verify_sign? params, key
      params = params.dup
      sign = params.delete('sign') || params.delete(:sign)
      generate_sign(params, key) == sign
    end

    def generate_sign params, key
      query = to_wx_string params
      Digest::MD5.hexdigest("#{query}&key=#{key}").upcase
    end

    def invoke_remote url, trade_details
      begin
        r = RestClient::Request.execute(
            {
                method: :post,
                url: url,
                payload: trade_details,
                headers: {content_type: 'application/xml'}
            }
        )
        r = Pay::WechatPayResult.new(Hash.from_xml(r))
        if r.success?
          r
        else
          logger.error("create wechat pay order failed ,detail:#{r['err_code']}-#{r['err_code_des']}")
          nil
        end
      rescue => e
        logger.error("create wechat pay order failed,detail:#{e.message}")
      end
    end
  end
end