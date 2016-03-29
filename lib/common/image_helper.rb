require 'rmagick'
require 'uuid'
require 'fileutils'

module Common
  class ImageHelper

    def save image_base64, folder
      FileUtils.mkdir_p(folder) unless Dir.exists?(folder)
      image = Magick::Image.from_blob(Base64.decode64(image_base64))
      image_path = "#{folder}/#{UUID.generate.to_s}.#{image[0].format.downcase!}"
      image[0].write(image_path)
      image_path
    end

    def generate_thumbnails original_image_path, small_file_path, scale=1
      img = Magick::Image.read(original_image_path).first
      c, r = img.columns, img.rows
      max = img.columns > img.rows ? img.columns : img.rows
      scale = 200.0/max
      thumb = img.thumbnail scale
      thumb.write(small_file_path)
    end

    def generate_s_image_path original_image_path
      image_dir = File.dirname original_image_path
      image_name = File.basename original_image_path
      "#{image_dir}/s_#{image_name}"
    end
  end
end