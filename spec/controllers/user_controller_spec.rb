#encoding:utf-8
require 'controllers/user_controller'
require 'common/image_helper'
require 'pandora/models/shop'
require 'pandora/models/account_log'

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

      it "should create designer for user if type is designer" do
        result = subject.login fake_phone, '1234', 'designer'
        user = Pandora::Models::User.find_by_phone_number(fake_phone)
        expect(user.designer.user_id).to eq user.id
        expect(result).to eq (
                                 {
                                     :status => "SUCCESS",
                                     :message => "操作成功",
                                     :data =>
                                         {
                                             :is_new => true,
                                             :user_id => 1,
                                             :designer_id => 1,
                                             :is_vip => false
                                         }
                                 }
                             )
      end
    end

    context "not new user" do
      before do
        Pandora::Models::User.create(phone_number: fake_phone, name: fake_phone)
      end

      it "should return right login result" do
        expect(subject.login fake_phone, '1234', nil).to eq (
                                                                {
                                                                    :status => "SUCCESS",
                                                                    :message => "操作成功",
                                                                    :data => {
                                                                        :is_new => false,
                                                                        :user_id => 1
                                                                    }
                                                                }
                                                            )
      end

      it "should create designer is_new is true if designer login fisrtly" do
        expect(subject.login fake_phone, '1234', 'designer').to eq (
                                                                       {
                                                                           :status => "SUCCESS",
                                                                           :message => "操作成功",
                                                                           :data => {
                                                                               :is_new => true,
                                                                               :user_id => 1,
                                                                               :designer_id => 1,
                                                                               :is_vip => false
                                                                           }
                                                                       }
                                                                   )
      end

      it "should return is_new is false if designer not nil" do
        create(:designer, user_id: 1)
        expect(subject.login fake_phone, '1234', 'designer').to eq (
                                                                       {
                                                                           :status => "SUCCESS",
                                                                           :message => "操作成功",
                                                                           :data => {
                                                                               :is_new => false,
                                                                               :user_id => 1,
                                                                               :designer_id => 1,
                                                                               :is_vip => true
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
                                                                    :message => "操作成功",
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
    let(:user) { create(:user, phone_number: "13812341234") }
    let(:designer) { create(:designer, user: user) }
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
      create(:account, {user: author, balance: 10})
    end

    after do
      FileUtils.rm_rf(fake_temp_images_folder)
      FileUtils.rm_rf(fake_images_folder)
    end

    it "should publish a new twitter" do
      expect(subject.publish_new_twitter(fake_author_id, fake_designer_id, fake_content, fake_temp_image_paths, fake_stars, fake_lat, fake_lon)).to eq (
                                                                                                                                                           {
                                                                                                                                                               :status => "SUCCESS",
                                                                                                                                                               :message => "发布动态成功.",
                                                                                                                                                               :data => {:twitter_id => 1}
                                                                                                                                                           }
                                                                                                                                                       )
    end

    it "should generate small image for upload images" do
      allow_any_instance_of(Pandora::Services::TwitterService).to receive(:create_twitter).and_raise StandardError,"create twitter failed"
      allow(File).to receive(:delete)
      expect{subject.publish_new_twitter(fake_author_id, fake_designer_id, fake_content, fake_temp_image_paths, fake_stars, fake_lat, fake_lon)}.to raise_error StandardError
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
      expect(twitter.images.map(&:s_url)).to eq (["temp_images/twitter/s_icon.jpg", "temp_images/twitter/s_icon.png"])
      expect(twitter.images.map(&:url)).to eq (["temp_images/twitter/icon.jpg", "temp_images/twitter/icon.png"])
      expect(twitter.author).to eq author
      expect(twitter.designer).to eq designer
      expect(twitter.content).to eq fake_content
      expect(twitter.latitude).to eq fake_lat
      expect(twitter.longitude).to eq fake_lon
      expect(twitter.stars).to eq 3
      expect(twitter.image_count).to eq 2
    end

    it "should update author's account balance" do
      subject.publish_new_twitter(fake_author_id, fake_designer_id, fake_content, fake_temp_image_paths, fake_stars, fake_lat, fake_lon)
      expect(Pandora::Models::User.find(author.id).account.balance).to eq 7
    end

    it "should add log for author's account" do
      subject.publish_new_twitter(fake_author_id, fake_designer_id, fake_content, fake_temp_image_paths, fake_stars, fake_lat, fake_lon)
      logs = Pandora::Models::Account.find(author.account.id).account_logs
      expect(logs.count).to eq 1
      expect(logs.first.desc).to eq "使用了3颗星星给user1点赞"
      expect(logs.first.channel).to eq "beautyshow"
    end

    it "should raise common error if author balance is not enough" do
      author.account.update(balance: 1)
      expect { subject.publish_new_twitter(fake_author_id, fake_designer_id, fake_content, fake_temp_image_paths, fake_stars, fake_lat, fake_lon) }.to raise_error Common::Error, '对不起,星星不够!'
    end

    it "should create message for designer" do
      subject.publish_new_twitter(fake_author_id, fake_designer_id, fake_content, fake_temp_image_paths, fake_stars, fake_lat, fake_lon)
      expect(Pandora::Models::User.find(designer.user.id).messages.count).to eq 1
      expect(Pandora::Models::User.find(designer.user.id).messages.first.content).to eq "user1发布了一条关于你的新动态,送给你3个赞"
      expect(Pandora::Models::User.find(designer.user.id).messages.first.is_new).to eq true
    end

    it "should update designer stars" do
      old_totally_stars = designer.totally_stars
      old_weekly_stars = designer.weekly_stars
      old_monthly_stars = designer.monthly_stars
      subject.publish_new_twitter(fake_author_id, fake_designer_id, fake_content, fake_temp_image_paths, fake_stars, fake_lat, fake_lon)
      new_designer = Pandora::Models::Designer.find(designer.id)
      expect(new_designer.totally_stars - old_totally_stars).to eq 3
      expect(new_designer.weekly_stars - old_weekly_stars).to eq 3
      expect(new_designer.monthly_stars - old_monthly_stars).to eq 3
    end

    it "should update author vitality" do
      old_vitality = author.vitality
      subject.publish_new_twitter(fake_author_id, fake_designer_id, fake_content, fake_temp_image_paths, fake_stars, fake_lat, fake_lon)
      expect(Pandora::Models::User.find(author.id).vitality - old_vitality).to eq fake_stars
    end

    it "should update use vitality" do
      old_vitality = designer.user.vitality
      subject.publish_new_twitter(fake_author_id, fake_designer_id, fake_content, fake_temp_image_paths, fake_stars, fake_lat, fake_lon)
      expect(Pandora::Models::User.find(designer.user.id).vitality - old_vitality).to eq fake_stars
    end
  end

  describe "#get_user_details" do
    context "no messages,no avatar, no twitters" do
      before do
        user = create(:user, phone_number: fake_phone)
        create(:account, user: user)
      end

      it "should return user details in correct json format" do
        expect(subject.get_user_details(1)).to eq(
                                                   {
                                                       :status => "SUCCESS",
                                                       :message => "操作成功",
                                                       :data =>
                                                           {
                                                               :id => 1,
                                                               :name => "user1",
                                                               :avatar => nil,
                                                               :vitality => 100,
                                                               :sex => "unknow",
                                                               :new_message_count => 0,
                                                               :balance => 10,
                                                               :twitter_count => 0,
                                                               :phone_number => "13812345678"
                                                           }
                                                   }
                                               )
      end
    end

    context "has all details" do
      before do
        image = create(:image)
        user = create(:user, {phone_number: fake_phone, avatar: image})
        designer = create(:designer, user: user)
        create(:account, user: user)
        create(:message, user: user)
        create(:twitter, {author: user, designer: designer})
      end

      it "should return user details in correct json format" do
        expect(subject.get_user_details(1)).to eq(
                                                   {
                                                       :status => "SUCCESS",
                                                       :message => "操作成功",
                                                       :data =>
                                                           {
                                                               :id => 1,
                                                               :name => "user1",
                                                               :avatar =>
                                                                   {
                                                                       :id => 1,
                                                                       :url => "images/1.jpg",
                                                                       :s_url => nil
                                                                   },
                                                               :vitality => 100,
                                                               :sex => "unknow",
                                                               :new_message_count => 1,
                                                               :balance => 10,
                                                               :twitter_count => 1,
                                                               :phone_number => "13812345678"
                                                           }
                                                   }
                                               )
      end

      it "should raise common error if user not exist" do
        expect { subject.get_user_details(10) }.to raise_error Common::Error, "该用户不存在."
      end
    end
  end

  describe "favorite images" do
    let(:image) { create(:image) }
    let(:user) { create(:user, {phone_number: fake_phone}) }
    let(:designer) { create(:designer, {user: user}) }
    let(:image) { create(:image) }
    let(:twitter) { create(:twitter, {author: user, designer: designer}) }
    let(:twitter_image) { create(:twitter_image, {twitter: twitter, image: image}) }

    before do
      create(:twitter_image, {twitter: twitter, image: image})
    end

    describe "#add_favorite_image" do
      it "should add favorite image" do
        subject.add_favorite_image user.id, image.id, twitter.id
        expect(user.favorite_images.count).to eq 1
      end

      it "should update twitter image likes" do
        old_likes = twitter.likes
        subject.add_favorite_image user.id, image.id, twitter.id
        expect(Pandora::Models::Twitter.find(twitter.id).likes - old_likes).to eq 1
      end

      it "should not add favorited if user has favorited image" do
        old_likes = twitter.likes
        subject.add_favorite_image user.id, image.id, twitter.id
        expect { subject.add_favorite_image user.id, image.id, twitter.id }.to_not raise_error
        expect(Pandora::Models::Twitter.find(twitter.id).likes - old_likes).to eq 1
      end
    end

    describe '#favorite_images' do
      let(:fake_result) {
        {
            :status => "SUCCESS",
            :message => "操作成功",
            :data =>
                [
                    {
                        :id => 1,
                        :twitter_id => 1,
                        :image =>
                            {
                                :id => 1,
                                :url => "images/1.jpg",
                                :s_url => nil
                            }
                    }
                ]
        }
      }
      before do
        create(:favorite_image, {user: user, favorited_image: image, twitter: twitter})
      end
      it "should return user favorite images in correct json format" do
        expect(subject.favorite_images user.id).to eq fake_result
      end
    end
  end

  describe "favorite designers" do
    let(:designer_user) { create(:user) }
    let(:shop) { create(:shop) }
    let(:designer) { create(:designer, {user: designer_user, shop: shop}) }
    let(:user) { create(:user, {phone_number: fake_phone}) }

    describe "#add_favorite_designer" do
      it "should add favorite designer" do
        subject.add_favorite_designer user.id, designer.id
        expect(user.favorite_designers.count).to eq 1
      end

      it "should update designer likes" do
        old_likes = designer.likes
        subject.add_favorite_designer user.id, designer.id
        expect(Pandora::Models::Designer.find(designer.id).likes - old_likes).to eq 1
      end

      it "should not add favorited if user has favorited designer" do
        old_likes = designer.likes
        subject.add_favorite_designer user.id, designer.id
        expect { subject.add_favorite_designer user.id, designer.id }.to_not raise_error
        expect(Pandora::Models::Designer.find(designer.id).likes - old_likes).to eq 1
      end
    end

    describe "#del_favorite_designer" do
      before do
        create(:favorite_designer, {user: user, favorited_designer: designer})
      end
      it "should del favorite designer by id" do
        subject.del_favorite_designers 1
        expect(user.favorite_designers.count).to eq 0
      end

      it "should del favorite designer by ids" do
        subject.del_favorite_designers [1]
        expect(user.favorite_designers.count).to eq 0
      end
    end

    describe '#favorite_designers' do
      let(:fake_result) {
        {
            :status => "SUCCESS",
            :message => "操作成功",
            :data =>
                [
                    {
                        :id => 1,
                        :designer =>
                            {
                                :id => 1,
                                :user_id => 2,
                                :name => "user1",
                                :avatar => nil,
                                :stars => 3,
                                :shop => {
                                    :id => 1,
                                    :name => "shop/1",
                                    :address => "zhuque street No.2",
                                    :latitude => "120.244",
                                    :longitude => "288.244"
                                }
                            }
                    }
                ]
        }
      }
      before do
        create(:favorite_designer, {user: user, favorited_designer: designer})
      end
      it "should return user favorite designers in correct json format" do
        expect(subject.favorite_designers user.id).to eq fake_result
      end
    end
  end

  describe "user twitter" do
    let(:user) { create(:user) }
    let(:author) { create(:user, phone_number: fake_phone) }
    let(:designer) { create(:designer, user: user) }
    let(:image) { create(:image) }
    let(:fake_result) {
      {
          :status => "SUCCESS",
          :message => "操作成功",
          :data =>
              [
                  {
                      :id => 1,
                      :author =>
                          {
                              :id => 1,
                              :name => "user1",
                              :avatar => nil
                          },
                      :content => "this is a test twitter",
                      :likes => 20,
                      :designer =>
                          {
                              :id => 1,
                              :user_id => 2,
                              :name => "user1",
                              :avatar => nil
                          },
                      :image_count => 1,
                      :images => [
                          {
                              :image =>
                                  {
                                      :id => 1,
                                      :url => "images/1.jpg",
                                      :s_url => "images/1.jpg"
                                  },
                              :likes => 20,
                              :rank => 1
                          }
                      ],
                      :created_at => "1小时前"
                  }
              ]
      }
    }

    before do
      allow_any_instance_of(Pandora::Models::Twitter).to receive(:relative_time).and_return("1小时前")
      twitter = create(:twitter, author: author, designer: designer)
      create(:image, original_image: image)
      create(:twitter_image, {twitter: twitter, image: image})
    end

    describe "#get_user_twitters" do
      it "should return user's twitters" do
        expect(subject.get_user_twitters(author.id, 1, 1)[:data].count).to eq 1
      end

      it "should return user's twitters in correct json format" do
        expect(subject.get_user_twitters(author.id, 1, 1)).to eq fake_result
      end
    end

    describe "#delete_twitter" do
      it "should return delete user's twitters" do
        subject.delete_twitter(author.id, 1)
        expect(author.twitters.count).to eq 0
      end
    end
  end

  describe "account" do
    let(:user) { create(:user) }
    describe "#get_account" do
      before do
        create(:account, user: user)
      end

      it "should return user account info" do
        expect(subject.get_account user.id).to eq(
                                                   {
                                                       :status => "SUCCESS",
                                                       :message => "操作成功",
                                                       :data =>
                                                           {
                                                               :id => 1,
                                                               :balance => 10
                                                           }
                                                   }
                                               )
      end
    end

    describe "#get_acount_logs" do

      before do
        allow_any_instance_of(Pandora::Models::AccountLog).to receive(:relative_time).and_return("1小时前")
        account = create(:account, {user: user, balance: 0})
        create(:account_log, {account: account, from_user: user.id, to_user: user.id, event: 'recharge', desc: 'this is a test log desc'})
        create(:account_log, {account: account, from_user: user.id, to_user: user.id, event: 'recharge', desc: 'this is a test log desc'})
      end

      it "should return user account logs" do
        expect(subject.get_account_logs(user.id, 5, 1)).to eq(
                                                               {
                                                                   :status => "SUCCESS",
                                                                   :message => "操作成功",
                                                                   :data =>
                                                                       [
                                                                           {
                                                                               :id => 1,
                                                                               :desc => "this is a test log desc",
                                                                               :balance => 10,
                                                                               :created_at => "1小时前"
                                                                           },
                                                                           {
                                                                               :id => 2,
                                                                               :desc => "this is a test log desc",
                                                                               :balance => 10,
                                                                               :created_at => "1小时前"
                                                                           }
                                                                       ]

                                                               }
                                                           )
      end
    end

    describe "#recharge" do
      let(:fake_out_trade_no) { "wx1215125" }

      before do
        create(:account, {user: user, balance: 0})
        create(:payment_log, {user_id: user.id, out_trade_no: fake_out_trade_no, plat_form: "WX", trade_status: "SUCCESS"})
      end

      it "should update user account balance" do
        subject.recharge user.id, 10, 'alipay', fake_out_trade_no
        expect(Pandora::Models::User.find(user.id).account.balance).to eq 10
      end

      it "should update user vitality" do
        old_value = user.vitality
        subject.recharge user.id, 10, 'alipay', fake_out_trade_no
        expect(Pandora::Models::User.find(user.id).vitality - old_value).to eq 10
      end

      it "should add acount log" do
        subject.recharge user.id, 10, 'alipay', fake_out_trade_no
        logs = Pandora::Models::Account.find(user.account.id).account_logs
        expect(logs.count).to eq 1
        expect(logs.first[:channel]).to eq 'alipay'
        expect(logs.first[:desc]).to eq '购买了10颗星星'
        expect(logs.first[:from_user]).to eq user.id
        expect(logs.first[:to_user]).to eq user.id
        expect(logs.first[:balance]).to eq 10
      end

      it "should return error if trade status is not success" do
        Pandora::Models::PaymentLog.update_all(:trade_status => "FAIL")
        expect(subject.recharge user.id, 10, 'alipay', fake_out_trade_no).to eq ({:status => "ERROR", :message => "买家付款不成功."})
      end
    end

    describe "#donate_stars" do
      let(:from_user) { create(:user, phone_number: '13812345678') }
      let(:to_user) { create(:user, phone_number: '13812345679') }
      before do
        create(:account, {user: from_user, balance: 10})
        create(:account, {user: to_user, balance: 0})
      end

      it "should update from_user's acount" do
        subject.donate_stars from_user.id, to_user.id, 10
        expect(Pandora::Models::Account.find(from_user.account.id).balance).to eq 0
      end

      it "should update to_user's acount" do
        subject.donate_stars from_user.id, to_user.id, 10
        expect(Pandora::Models::Account.find(to_user.account.id).balance).to eq 10
      end

      it "should add log for from_user's account" do
        subject.donate_stars from_user.id, to_user.id, 10
        logs = Pandora::Models::Account.find(from_user.account.id).account_logs
        expect(logs.count).to eq 1
        expect(logs.first[:channel]).to eq 'beautyshow'
        expect(logs.first[:event]).to eq 'donate'
        expect(logs.first[:from_user]).to eq from_user.id
        expect(logs.first[:to_user]).to eq to_user.id
        expect(logs.first[:balance]).to eq -10
        expect(logs.first[:desc]).to eq '赠送给user110颗星星'
      end

      it "should add log for to_user's account" do
        subject.donate_stars from_user.id, to_user.id, 10
        logs = Pandora::Models::Account.find(to_user.account.id).account_logs
        expect(logs.count).to eq 1
        expect(logs.first[:channel]).to eq 'beautyshow'
        expect(logs.first[:event]).to eq 'donate'
        expect(logs.first[:from_user]).to eq from_user.id
        expect(logs.first[:to_user]).to eq to_user.id
        expect(logs.first[:balance]).to eq 10
        expect(logs.first[:desc]).to eq '收到user1赠送给你的10颗星星'
      end

      it "should create message for to_user" do
        subject.donate_stars from_user.id, to_user.id, 10
        expect(Pandora::Models::User.find(to_user.id).messages.count).to eq 1
        expect(Pandora::Models::User.find(to_user.id).messages.first.content).to eq "收到user1赠送给你的10颗星星"
        expect(Pandora::Models::User.find(to_user.id).messages.first.is_new).to eq true
      end
    end
  end
  describe "message" do
    let(:user) { create(:user, phone_number: fake_phone) }
    let(:fake_result) {
      {
          :status => "SUCCESS",
          :message => "操作成功",
          :data =>
              [
                  {
                      :id => 1,
                      :content => "this is a test message",
                      :created_at => "1小时前",
                      :is_new => false
                  },
                  {
                      :id => 2,
                      :content => "this is a test message",
                      :created_at => "1小时前",
                      :is_new => false
                  }
              ]
      }
    }

    before do
      allow_any_instance_of(Pandora::Models::Message).to receive(:relative_time).and_return("1小时前")
      create(:message, user: user)
      create(:message, user: user)
    end

    describe "#messages" do
      it "should return user's messages" do
        expect(subject.messages user.id).to eq fake_result
      end

      it "should update user's messages to be read" do
        subject.messages user.id
        expect(Pandora::Models::User.find(user.id).messages.all? { |m| !m.is_new }).to be true
      end
    end

    describe "#delete_message" do
      it "should delete message" do
        subject.delete_message user.messages.first.id
        expect(Pandora::Models::User.find(user.id).messages.count).to eq 1
      end
    end
  end

  describe "#modify_avatar" do
    let(:user) { create(:user) }
    let(:fake_images_folder) { "temp_images" }
    let(:fake_temp_images_folder) { "spec/temp_images" }
    let(:fake_temp_image_path) { "#{fake_temp_images_folder}/icon.jpg" }
    let(:fake_image_path) { "spec/fixtures/icon.jpg" }

    before do
      FileUtils.mkdir_p(fake_temp_images_folder) unless Dir.exists?(fake_temp_images_folder)
      FileUtils.cp(fake_image_path, "#{fake_temp_images_folder}/#{File.basename(fake_image_path)}")
      allow(ENV).to receive(:[]).with('IMGAES_FOLDER').and_return fake_images_folder
    end

    after do
      FileUtils.rm_rf(fake_temp_images_folder)
      FileUtils.rm_rf(fake_images_folder)
    end

    it "should update user avatar" do
      subject.modify_avatar user.id, fake_temp_image_path
      expect(Pandora::Models::User.find(user.id).avatar.attributes).to eq (
                                                                              {
                                                                                  :id => 1,
                                                                                  :url => "temp_images/avatar/icon.jpg",
                                                                                  :s_url => "temp_images/avatar/s_icon.jpg"
                                                                              }
                                                                          )
    end

    it "should move image from temp folder to twitter folder" do
      subject.modify_avatar(user.id, fake_temp_image_path)
      expect(Dir["#{fake_temp_images_folder}/*"].length).to eq 0
      expect(Dir["#{fake_images_folder}/avatar/*"].length).to eq 2
    end

    it "should delete temp file if raise error when create twitter" do
      allow_any_instance_of(Pandora::Services::UserService).to receive(:update_user_avatar).and_raise StandardError
      expect { subject.modify_avatar(user.id, fake_temp_image_path) }.to raise_error StandardError
      expect(Dir["#{fake_temp_images_folder}/*"].length).to eq 0
    end
  end

  describe "#modify_gender" do
    let(:user) { create(:user, {gender: 'unknow'}) }
    it "should update user gender" do
      subject.modify_gender user.id, "male"
      expect(Pandora::Models::User.find(user.id).gender).to eq "male"
    end
  end

  describe "#modify_name" do
    let(:user) { create(:user, {name: 'unknow'}) }
    it "should update user name" do
      subject.modify_name user.id, "new name"
      expect(Pandora::Models::User.find(user.id).name).to eq "new name"
    end
  end
end