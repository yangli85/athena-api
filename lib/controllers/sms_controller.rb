#encoding:utf-8
require 'pandora/services/sms_service'
require 'controllers/base_controller'

class SmsController < BaseController
  def initialize
    @sms_service = Pandora::Services::SMSService.new
  end

  def send_sms_code phone_number
    code = rand 1000..10000
    sms = "欢迎您登录美丽秀,你的短信验证码是:#{code}"
    @sms_service.send sms, phone_number
    @sms_service.update_code phone_number, code
    success.merge({message: '短信发送成功'})
  end
end