#encoding:utf-8
require 'controllers/base_controller'
require 'pandora/services/user_service'
require 'pandora/services/sms_service'
require 'common/error'

class UserController < BaseController
  def initialize
    @user_service = Pandora::Services::UserService.new
    @sms_service =Pandora::Services::SMSService.new
  end

  def login phone_number, code
    raise Common::Error.new("短信验证码错误") unless correct_code? phone_number, code
    user = @user_service.get_user phone_number
    is_new = false
    if user.nil?
      user = @user_service.create_user phone_number
      is_new = true
    end
    success.merge({
                      data: {
                          is_new: is_new,
                          user_id: user.id
                      }
                  })
  end

  private
  def correct_code? phone_number, code
    latest_sms_code = @sms_service.get_latest_code phone_number
    !latest_sms_code.nil? && code == latest_sms_code.code
  end
end