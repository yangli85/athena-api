#encoding:utf-8
require 'controllers/base_controller'
require 'pandora/services/user_service'
require 'pandora/services/sms_service'
require 'pandora/services/twitter_service'
require 'common/error'
require 'common/image_helper'

class UserController < BaseController
  def initialize
    @user_service = Pandora::Services::UserService.new
    @sms_service =Pandora::Services::SMSService.new
    @twitter_service =Pandora::Services::TwitterService.new
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

  def upload_image image_base_64
    temp_image_path = Common::ImageHelper.new.save(image_base_64, ENV['TEMP_IMAGES_FOLDER'])
    success.merge(data: {temp_image_path: temp_image_path})
  end

  def publish_new_twitter author_id, designer_id, content, image_paths, stars, latitude, longtitude
    image_paths = generate_small_images image_paths
    begin
      @twitter_service.create_twitter author_id, designer_id, content, image_paths, stars, latitude, longtitude, twitter_image_folder
      success.merge({message: "发布成功!"})
    ensure
      image_paths.each do |path|
        File.delete(path[:image_path]) if File.exist? path[:image_path]
        File.delete(path[:s_image_path]) if File.exist? path[:s_image_path]
      end
    end
  end

  private
  def generate_small_images image_paths
    image_helper = Common::ImageHelper.new
    image_paths.map do |image_path|
      s_image_path = image_helper.generate_s_image_path image_path
      image_helper.generate_thumbnails image_path, s_image_path
      {
          image_path: image_path,
          s_image_path: s_image_path
      }
    end
  end

  def twitter_image_folder
    folder = "#{ENV["IMGAES_FOLDER"]}/twitter"
    FileUtils.mkdir_p(folder) unless Dir.exists?(folder)
    folder
  end

  def correct_code? phone_number, code
    latest_sms_code = @sms_service.get_latest_code phone_number
    !latest_sms_code.nil? && code == latest_sms_code.code
  end
end