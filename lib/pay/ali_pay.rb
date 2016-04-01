require 'rest_client'
require 'active_support/core_ext/hash/conversions'
require "pay/utils"
require 'common/logging'
require 'openssl'
require 'base64'
require 'alipay'

module Pay
  class AliPay
    include Common::Logging
    include Pay::Utils
    GATEWAY_URL = 'https://mapi.alipay.com/gateway.do'
    GENERATE_APP_PAY_REQ_REQUIRED_FIELDS = ['service', 'partner', '_input_charset', 'notify_url', 'out_trade_no', 'subject', 'payment_type', 'seller_id', 'total_fee', 'body']

    def initialize
      @public_key = OpenSSL::PKey::RSA.new File.read 'config/pem/rsa_public_key.pem'
      @private_key = OpenSSL::PKey::RSA.new File.read 'config/pem/rsa_private_key.pem'
      @mch_id = ENV['ALI_MCH_ID']
    end

    def generate_pay_req_by_gem params, out_trade_no
      params.merge!(:out_trade_no => out_trade_no)
      Alipay.pid = @mch_id
      Alipay.key = @private_key
      Alipay.sign_type = "RSA"
      Alipay::Mobile::Service.mobile_securitypay_pay_string(params)
    end

    def generate_pay_req params, out_trade_no
      params = change_key_to_sym params
      params.merge!(
          {
              service: "mobile.securitypay.pay",
              partner: @mch_id,
              _input_charset: "utf-8",
              out_trade_no: out_trade_no,
              payment_type: "1",
              seller_id: @mch_id
          }
      )
      check_required_options(params, GENERATE_APP_PAY_REQ_REQUIRED_FIELDS)
      params.merge(
          {
              sign_type: "RSA",
              sign: generate_sign(params, @private_key)
          }
      )
    end

    def verify? params
      verify_rsa_sign?(params, @public_key) && verify_notify_id?(@mch_id, params['notify_id'])
    end


    private
    def generate_sign params, key
      query = stringify params
      rsa = OpenSSL::PKey::RSA.new(key)
      Base64.strict_encode64(rsa.sign('sha1', query))
    end

    def verify_notify_id? pid, notify_id
      uri = URI(GATEWAY_URL)
      uri.query = URI.encode_www_form(
          'service' => 'notify_verify',
          'partner' => pid,
          'notify_id' => notify_id
      )
      Net::HTTP.get(uri) == 'true'
    end

    def verify_rsa_sign? params, key
      sign = params.delete('sign') || params.delete(:sign)
      sign_type = params.delete('sign_type') || params.delete(:sign_type)
      query = stringify params
      rsa = OpenSSL::PKey::RSA.new(key)
      rsa.verify('sha1', Base64.strict_decode64(sign), query)
    end

    def invoke_remote url, trade_details
      r = RestClient::Request.execute(
          {
              method: :post,
              url: url,
              payload: trade_details,
              headers: {content_type: 'application/xml'}
          }
      )

      Pay::WechatPayResult.new(Hash.from_xml(r))
    end
  end
end