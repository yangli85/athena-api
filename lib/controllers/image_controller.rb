require 'controllers/base_controller'
require 'uuid'
class ImageController < BaseController
  def initialize
    @temp_image_dir = './lib/temp_images'
  end

  def save_temp_image image_base64, image_type
    image_path = "#{@temp_image_dir}/#{UUID.generate.to_s}.#{image_type}"

    image_path
  end
end