require 'common/image_helper'
module Common
  module ControllerHelper
    def rebuild_images image_paths
      image_paths.map do |image_path|
        {
            image_path: image_path,
            s_image_path: generate_small_image(image_path)
        }
      end
    end

    def generate_small_image image_path
      image_helper = Common::ImageHelper.new
      s_image_path = image_helper.generate_s_image_path image_path
      image_helper.generate_thumbnails image_path, s_image_path
      s_image_path
    end

    def twitter_image_folder
      folder = "#{ENV["IMGAES_FOLDER"]}/twitter"
      FileUtils.mkdir_p(folder) unless Dir.exists?(folder)
      folder
    end

    def avatar_image_folder
      folder = "#{ENV["IMGAES_FOLDER"]}/avatar"
      FileUtils.mkdir_p(folder) unless Dir.exists?(folder)
      folder
    end

    def vita_image_folder
      folder = "#{ENV["IMGAES_FOLDER"]}/vita"
      FileUtils.mkdir_p(folder) unless Dir.exists?(folder)
      folder
    end
  end
end