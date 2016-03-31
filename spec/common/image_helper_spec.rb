require 'common/image_helper'

describe Common::ImageHelper do
  let(:fake_image_base64) { File.read('spec/fixtures/sample_image_base64.txt') }
  let(:fake_png_path) { "spec/fixtures/icon.png" }
  let(:fake_jpg_path) { "spec/fixtures/icon.jpg" }
  let(:fake_jpeg_path) { "spec/fixtures/icon.jpeg" }
  let(:fake_folder) { "temp_images" }
  let(:fake_small_png_path) { "#{fake_folder}/s_icon.png" }
  let(:fake_small_jpg_path) { "#{fake_folder}/s_icon.jpg" }
  let(:fake_small_jpeg_path) { "#{fake_folder}/s_icon.jpeg" }

  describe "#save" do
    it "should save the image" do
      image_path = subject.save fake_image_base64, fake_folder
      expect(File.exist?(image_path)).to eq true
    end
  end

  describe "#generate_thumbnails" do
    after(:all) do
      require 'fileutils'
      FileUtils.rm_rf('temp_images')
    end

    it "should generate_thumbnails for png image" do
      image_path = subject.generate_thumbnails fake_png_path, fake_small_png_path, 0.25
      expect(File.exist?(fake_small_png_path)).to eq true
    end

    it "should generate_thumbnails for jpg image" do
      image_path = subject.generate_thumbnails fake_jpg_path, fake_small_jpg_path, 0.25
      expect(File.exist?(fake_small_jpg_path)).to eq true
    end

    it "should generate_thumbnails for jpeg image" do
      image_path = subject.generate_thumbnails fake_jpeg_path, fake_small_jpeg_path, 0.25
      expect(File.exist?(fake_small_jpg_path)).to eq true
    end
  end

end