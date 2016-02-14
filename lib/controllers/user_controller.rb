#encoding:utf-8
require 'pandora/services/user_service'
require 'pandora/services/sms_service'

class UserController
  def initialize
    @user_service = Pandora::Services::UserService.new
    @sms_service =Pandora::Services::SMSService.new
  end

  def login phone_number, code
    begin
      return error '短信验证码错误!' if correct_code? phone_number, code
      is_new = false
      user = @user_service.get_user phone_number
      if user.nil?
        user = @user_service.create_user phone_number
        is_new = true
      end
      {
          result: 'success',
          message: '登录成功',
          is_new: is_new,
          user_id: user.id
      }
    rescue => e
      error '对不起,登录失败,请您稍后再试!'
    end
  end

  private
  def correct_code? phone_number, code
    latest_sms_code = @sms_service.get_latest_code phone_number
    latest_sms_code.nil? || code != latest_sms_code.code
  end

  def error message
    {
        result: 'error',
        message: message
    }
  end
end