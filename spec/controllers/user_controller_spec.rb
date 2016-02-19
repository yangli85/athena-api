#encoding:utf-8
require 'controllers/user_controller'
require 'common/image_helper'

describe UserController do
  let(:fake_phone) { '13812345678' }
  describe "#login" do
    before do
      Pandora::Models::SMSCode.create(phone_number: fake_phone, code: '1234')
    end

    context 'failed' do

      it "should raise common error with correct messsage if latest sms code is nil" do
        Pandora::Models::SMSCode.destroy_all
        expect { subject.login fake_phone, '1234' }.to raise_error Common::Error, "短信验证码错误"
      end
      it "should raise common error with correct messsage if code not match" do
        Pandora::Models::SMSCode.find_by_phone_number(fake_phone).update(code: '2345')
        expect { subject.login fake_phone, '1234' }.to raise_error Common::Error, "短信验证码错误"
      end

      it "shoule return error if have exception in login" do
        allow_any_instance_of(Pandora::Services::UserService).to receive(:create_user).and_raise StandardError
        expect { subject.login fake_phone, '1234' }.to raise_error StandardError
      end
    end

    context 'new user' do
      it "should create a new user for given phone number" do
        subject.login fake_phone, '1234'
        expect(Pandora::Models::User.find_by_phone_number(fake_phone).name).to eq fake_phone
      end

      it "should return is_new user" do
        result = subject.login fake_phone, '1234'
        expect(result[:data][:is_new]).to eq true
      end
    end

    context "not new user" do
      before do
        Pandora::Models::User.create(phone_number: fake_phone, name: fake_phone)
      end

      it "should return right login result" do
        expect(subject.login fake_phone, '1234').to eq (
                                                           {
                                                               :status => "SUCCESS",
                                                               :data => {
                                                                   :is_new => false,
                                                                   :user_id => 1
                                                               }
                                                           }
                                                       )
      end
    end
  end

  describe "#upload_twitter_image" do
    let(:fake_image_base_64) { "iVBORw0KGg" }
    let(:fake_temp_images_folder) { "temp_images" }
    let(:fake_temp_images_path) { "temp_images/temp.jpg" }
    let(:fake_image_helper) { double('Common::ImageHelper') }

    before do
      allow(ENV).to receive(:[]).with('TEMP_IMAGES_FOLDER').and_return(fake_temp_images_folder)
      allow(Common::ImageHelper).to receive(:new).and_return(fake_image_helper)
      allow(fake_image_helper).to receive(:save).and_return(fake_temp_images_path)
    end

    it "should save image" do
      expect(fake_image_helper).to receive(:save).with(fake_image_base_64, fake_temp_images_folder)
      subject.upload_image fake_image_base_64
    end

    it "should return temp_image_path" do
      expect(subject.upload_image fake_image_base_64).to eq (
                                                                {
                                                                    :status => "SUCCESS",
                                                                    :data =>
                                                                        {
                                                                            :temp_image_path => "temp_images/temp.jpg"
                                                                        }
                                                                }
                                                            )
    end
  end

  describe "#publish_new_twitter" do

    let(:author) { create(:user, phone_number: fake_phone) }
    let(:designer) { create(:designer, user: author) }
    let(:fake_author_id) { author.id }
    let(:fake_designer_id) { designer.id }
    let(:fake_content) { 'new twitter' }
    let(:fake_stars) { 3 }
    let(:fake_lon) { "108.124" }
    let(:fake_lat) { "89.124" }
    let(:fake_images_folder) { "temp_images" }
    let(:fake_temp_images_folder) { "spec/temp_images" }
    let(:fake_temp_image_paths) { ["#{fake_temp_images_folder}/icon.jpg", "#{fake_temp_images_folder}/icon.png"] }
    let(:fake_image_paths) { ["spec/fixtures/icon.jpg", "spec/fixtures/icon.png"] }

    before do
      FileUtils.mkdir_p(fake_temp_images_folder) unless Dir.exists?(fake_temp_images_folder)
      fake_image_paths.each do |path|
        FileUtils.cp(path, "#{fake_temp_images_folder}/#{File.basename(path)}")
      end
      allow(ENV).to receive(:[]).with('IMGAES_FOLDER').and_return fake_images_folder
    end

    after do
      FileUtils.rm_rf(fake_temp_images_folder)
      FileUtils.rm_rf(fake_images_folder)
    end

    it "should publish a new twitter" do
      expect(subject.publish_new_twitter(fake_author_id, fake_designer_id, fake_content, fake_temp_image_paths, fake_stars, fake_lat, fake_lon)).to eq (
                                                                                                                                                           {
                                                                                                                                                               :status => "SUCCESS",
                                                                                                                                                               :message => "发布成功!"
                                                                                                                                                           }
                                                                                                                                                       )
    end

    it "should generate small image for upload images" do
      allow_any_instance_of(Pandora::Services::TwitterService).to receive(:create_twitter)
      allow(File).to receive(:delete)
      subject.publish_new_twitter(fake_author_id, fake_designer_id, fake_content, fake_temp_image_paths, fake_stars, fake_lat, fake_lon)
      fake_temp_image_paths.each do |path|
        expect(File.exist?(Common::ImageHelper.new.generate_s_image_path path)).to eq true
      end
    end

    it "should move image from temp folder to twitter folder" do
      subject.publish_new_twitter(fake_author_id, fake_designer_id, fake_content, fake_temp_image_paths, fake_stars, fake_lat, fake_lon)
      expect(Dir["#{fake_temp_images_folder}/*"].length).to eq 0
      expect(Dir["#{fake_images_folder}/twitter/*"].length).to eq 4
    end

    it "should delete temp file if raise error when create twitter" do
      allow_any_instance_of(Pandora::Services::TwitterService).to receive(:create_twitter).and_raise StandardError
      expect { subject.publish_new_twitter(fake_author_id, fake_designer_id, fake_content, fake_temp_image_paths, fake_stars, fake_lat, fake_lon) }.to raise_error StandardError
      expect(Dir["#{fake_temp_images_folder}/*"].length).to eq 0
    end

    it "should create a new twitter" do
      subject.publish_new_twitter(fake_author_id, fake_designer_id, fake_content, fake_temp_image_paths, fake_stars, fake_lat, fake_lon)
      twitter = author.twitters.first
      expect(twitter.s_images.map(&:url)).to eq (["temp_images/twitter/s_icon.jpg", "temp_images/twitter/s_icon.png"])
      expect(twitter.images.map(&:url)).to eq (["temp_images/twitter/icon.jpg", "temp_images/twitter/icon.png"])
      expect(twitter.author).to eq author
      expect(twitter.designer).to eq designer
      expect(twitter.content).to eq fake_content
      expect(twitter.latitude).to eq fake_lat
      expect(twitter.longtitude).to eq fake_lon
      expect(twitter.stars).to eq 3
      expect(twitter.image_count).to eq 2
    end
  end
end