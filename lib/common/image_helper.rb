require 'rmagick'
require 'uuid'
require 'fileutils'
require "open-uri"
require 'fastimage'

module Common
  class ImageHelper

    def save image_base64, folder
      FileUtils.mkdir_p(folder) unless Dir.exists?(folder)
      image = Magick::Image.from_blob(Base64.decode64(image_base64))
      image_path = "#{folder}/#{UUID.generate.to_s}.#{image[0].format.downcase!}"
      image[0].write(image_path)
      image_path
    end

    def generate_thumbnails original_image_path, small_file_path, scale=0.5
      img = Magick::Image.read(original_image_path).first
      thumb = img.resize_to_fill(400, 400)
      thumb = thumb.thumbnail scale
      thumb.write(small_file_path)
    end

    def generate_s_image_path original_image_path
      image_dir = File.dirname original_image_path
      image_name = File.basename original_image_path
      "#{image_dir}/s_#{image_name}"
    end

    def generate_code_image c_id, image_folder
      image_path = "#{image_folder}/#{c_id}.png"
      FileUtils.mkdir_p(ENV['TEMP_IMAGES_FOLDER']) unless Dir.exists?(ENV['TEMP_IMAGES_FOLDER'])
      open("http://qr.liantu.com/api.php?text=#{ENV['DOWNLOAD_URL']}?c_id=#{c_id}") { |f|
        File.open(image_path, "wb") do |file|
          file.puts f.read
        end
      }
      image_path
    end
  end
end