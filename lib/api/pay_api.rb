require 'controllers/ali_pay_controller'
require 'controllers/wechat_pay_controller'
module API
  class PayAPI
    def self.registered(app)
      app.get '/generate_ali_pay_req' do
        callback = params.delete('callback') # jsonp
        result = AliPayController.call(:generate_pay_req, [params])
        return_response callback, result
      end

      app.get '/generate_wx_pay_req' do
        callback = params.delete('callback') # jsonp
        params.merge!({"spbill_create_ip" => request.ip})
        result = WechatPayController.call(:generate_pay_req, [params])
        return_response callback, result
      end

      app.post '/notify/ali_notify' do
        callback = params.delete('callback') # jsonp
        AliPayController.call(:notify, [params])
      end

      app.post '/notify/wx_notify' do
        callback = params.delete('callback') # jsonp
        result = WechatPayController.call(:notify, [params])
        result.to_xml
      end
    end
  end
end




