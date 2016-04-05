#encoding:utf-8
require 'net/http'

module Sms
  class AthenaSms

    def initialize
      @app_key = ENV['SMS_APP_KEY']
      @app_secret = ENV['SMS_APP_SECRET']
      @post_url = ENV['SMS_POST_URL']
      @mch_id = ENV['ALI_MCH_ID']
      @product = ENV['PRODUCT']
    end

    def send_msg phone, code, sign_name
      options = {
          method: 'alibaba.aliqin.fc.sms.num.send',
          app_key: @app_key,
          timestamp: Time.now.strftime("%F %T"),
          format: 'json',
          v: '2.0',
          partner_id: @mch_id,
          sign_method: 'md5',
          sms_type: 'normal',
          sms_free_sign_name: sign_name,
          rec_num: phone,
          sms_param: "{'code':'#{code}','product':'#{@product}'}",
          sms_template_code: "SMS_6690792"
      }
      options = sort_options(options)
      sign = generate_sign(options)
      response = post(@post_url, options.merge(sign: sign))
      p options
      p response
      unless response['alibaba_aliqin_fc_sms_num_send_response'].nil?
        response['alibaba_aliqin_fc_sms_num_send_response']['result']['success']
      else
        false
      end
    end

    private
    def sort_options options
      options.sort_by { |k, v| k }.to_h
    end

    def generate_sign options
      _options = options.map { |k, v| "#{k}#{v}" }
      Digest::MD5.hexdigest("#{@app_secret}#{_options.join("")}#{@app_secret}").upcase
    end

    def post(uri, options)
      response = ""
      url = URI.parse(uri)
      Net::HTTP.start(url.host, url.port) do |http|
        req = Net::HTTP::Post.new(url.path)
        req.set_form_data(options)
        response = http.request(req).body
      end
      JSON(response)
    end
  end
end
