#encoding:utf-8
require 'pandora/services/sms_service'

class SmsController
  def initialize
    @sms_service = Pandora::Services::SMSService.new
  end

  def send_sms_code phone_number
    begin
      code = rand 1000..10000
      message = "欢迎您登录美丽秀,你的短信验证码是:#{code}"
      @sms_service.send message, phone_number
      @sms_service.update_code phone_number, code
      {
          result: "success",
          message: "短信验证码发送成功!"
      }
    rescue => e
      {
          result: 'error',
          message: '短信验证码发送失败!'
      }
    end
  end
end