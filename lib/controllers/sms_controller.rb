#encoding:utf-8
require 'pandora/services/sms_service'
require 'controllers/base_controller'
require 'sms/athena_sms'
require 'common/logging'

class SmsController < BaseController
  LOGIN_SMS = "登录验证"

  include Common::Logging

  def initialize
    @athena_sms = Sms::AthenaSms.new
    @sms_service = Pandora::Services::SMSService.new
  end

  def send_login_sms_code phone_number
    code = rand 1000..10000
    if @athena_sms.send_msg phone_number, code, LOGIN_SMS
      logger.info("send sms to #{phone_number},code is #{code}")
      @sms_service.update_code phone_number, code
      success.merge({message: '短信发送成功'})
    else
      error("对不起,不能频繁的获取短信验证码.")
    end
  end
end