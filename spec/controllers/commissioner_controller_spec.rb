#encoding:utf-8
require 'controllers/commissioner_controller'

describe CommissionerController do
  let(:fake_phone) { "13812345678" }
  let(:created_at) { DateTime.parse("20151212121212") }

  before do
    allow(Time).to receive(:now).and_return(created_at)
  end

  describe "#register" do
    before do
      allow(FileUtils).to receive(:mv)
    end

    context "common error" do
      it "should raise common error if commissioner already exist" do
        create(:commissioner, phone_number: fake_phone)
        expect { subject.register fake_phone, "new", "123456", '8888' }.to raise_error Common::Error, "大王,你已经是我们的人了,可以直接登录."
      end
    end

    context "normal" do
      before do
        allow_any_instance_of(Pandora::Services::SMSService).to receive_message_chain(:get_latest_code, :code).and_return("1234")
        allow(ENV).to receive(:[]).with("IMGAES_FOLDER").and_return("images")
        allow(ENV).to receive(:[]).with("TEMP_IMAGES_FOLDER").and_return("temp_images")
        allow_any_instance_of(Common::ImageHelper).to receive(:generate_code_image).and_return("temp_images/1.png")
      end

      it "should create new commissioner successfully" do
        subject.register fake_phone, "new", "123456", "1234"
        new_commissioner = Pandora::Models::Commissioner.find_by_phone_number(fake_phone)
        expect(new_commissioner.phone_number).to eq fake_phone
        expect(new_commissioner.code_image.url).to eq 'images/code/1.png'
        expect(new_commissioner.name).to eq "new"
        expect(new_commissioner.password).to eq '123456'
      end

      it "should return correct messages" do
        expect(subject.register fake_phone, "new", "123456", "1234").to eq (
                                                                               {
                                                                                   :status => "SUCCESS",
                                                                                   :message => "恭喜你,注册成功,下一个地推之王非你莫属!"
                                                                               }
                                                                           )
      end
    end
  end

  describe "#login" do
    it "should login success" do
      commissioner = create(:commissioner, {phone_number: fake_phone, name: "曹操"})
      expect(subject.login commissioner.phone_number, commissioner.password).to eq (
                                                                                       {
                                                                                           :status => "SUCCESS",
                                                                                           :message => "欢迎大将军曹操回归!",
                                                                                           :c_id => 1,
                                                                                           :c_name => "曹操"
                                                                                       }
                                                                                   )
    end

    context "common error" do
      it "should raise common error if commissioner not exist" do
        expect { subject.login fake_phone, "123456" }.to raise_error Common::Error, "将军你还不是臣妾的人,赶快注册加入吧!"
      end

      it "should raise common error if password is incorrect" do
        create(:commissioner, phone_number: fake_phone)
        expect { subject.login fake_phone, '123456' }.to raise_error Common::Error, "密码错啦,想找回密码就联系臣妾吧!"
      end
    end
  end

  describe "#promotion_logs" do
    let(:commissioner) { create(:commissioner, phone_number: fake_phone) }
    let(:fake_result) {
      {
          :status => "SUCCESS",
          :message => "操作成功",
          :data =>
              [
                  {
                      :id => 1,
                      :phone_number => nil,
                      :mobile_type => "unknow",
                      :created_at => created_at
                  },
                  {
                      :id => 2,
                      :phone_number => "13812345678",
                      :mobile_type => "unknow",
                      :created_at => created_at
                  }
              ]
      }
    }

    before do
      create(:promotion_log, commissioner: commissioner)
      create(:promotion_log, {c_id: commissioner.id, phone_number: fake_phone})
    end

    it "should return all promotion logs in correct json format" do
      expect(subject.promotion_logs commissioner.id, 2, 1).to eq fake_result
    end
  end

  describe "#add_promotion_log" do
    it "should add promotion log successfully" do
      commissioner = create(:commissioner)
      subject.add_promotion_log commissioner.id, fake_phone, 'iphone'
      expect(Pandora::Models::Commissioner.find(commissioner.id).promotion_logs.count).to eq 1
      expect(Pandora::Models::Commissioner.find(commissioner.id).promotion_logs.first.attributes).to eq (
                                                                                                            {
                                                                                                                :id => 1,
                                                                                                                :phone_number => "13812345678",
                                                                                                                :mobile_type => "iphone",
                                                                                                                :created_at => created_at
                                                                                                            }
                                                                                                        )
    end
  end

  describe "#del_promotion_log" do
    it "should del promotion log" do
      commissioner = create(:commissioner)
      log = create(:promotion_log, c_id: commissioner.id)
      subject.del_promotion_log log.id
      expect { Pandora::Models::PromotionLog.find(log.id) }.to raise_error ActiveRecord::RecordNotFound
    end
  end

  describe "#promotion_users" do
    let(:commissioner) { create(:commissioner) }
    let(:fake_phone1) { '13800000001' }
    let(:fake_phone2) { '13800000002' }
    let(:fake_result) {
      {
          :status => "SUCCESS",
          :message => "操作成功",
          :data =>
              [
                  {
                      :id => 1,
                      :name => "user1",
                      :avatar => nil,
                      :phone_number => "13800000001",
                      :created_at => created_at
                  },
                  {
                      :id => 2,
                      :name => "user1",
                      :avatar => nil,
                      :phone_number => "13800000002",
                      :created_at => created_at
                  }
              ]
      }
    }

    before do
      create(:promotion_log, commissioner: commissioner)
      create(:promotion_log, {c_id: commissioner.id, phone_number: fake_phone1})
      create(:promotion_log, {c_id: commissioner.id, phone_number: fake_phone2})
      create(:promotion_log, {c_id: commissioner.id, phone_number: '13811111113'})
      create(:user, phone_number: fake_phone1)
      create(:user, phone_number: fake_phone2)
    end

    it "should return all promotion users for commissioner" do
      expect(subject.promotion_users(commissioner.id, 2, 1)[:data].count).to eq 2
    end

    it "should return all promotion users in correct json format" do
      expect(subject.promotion_users(commissioner.id, 2, 1)).to eq fake_result
    end
  end

  describe "#promotion_designers" do
    let(:commissioner) { create(:commissioner) }
    let(:fake_phone1) { '13800000001' }
    let(:fake_phone2) { '13800000002' }
    let(:fake_result) {
      {
          :status => "SUCCESS",
          :message => "操作成功",
          :data =>
              [
                  {
                      :id => 1,
                      :user_id => 1,
                      :name => "user1",
                      :avatar => nil,
                      :phone_number => "13800000001",
                      :created_at => created_at
                  }
              ]
      }
    }

    before do
      create(:promotion_log, commissioner: commissioner)
      create(:promotion_log, {c_id: commissioner.id, phone_number: fake_phone1})
      create(:promotion_log, {c_id: commissioner.id, phone_number: fake_phone2})
      create(:promotion_log, {c_id: commissioner.id, phone_number: '13811111113'})
      user1 = create(:user, phone_number: fake_phone1)
      user2 = create(:user, phone_number: fake_phone2)
      create(:designer, user: user1)
    end

    it "should return all promotion designers for commissioner" do
      expect(subject.promotion_designers(commissioner.id, 2, 1)[:data].count).to eq 1
    end

    it "should return all promotion designers in correct json format" do
      expect(subject.promotion_designers(commissioner.id, 2, 1)).to eq fake_result
    end
  end

  describe "#shop_promotion_logs" do
    let(:commissioner) { create(:commissioner) }
    let(:shop) { create(:shop) }
    let(:fake_result) {
      {
          :status => "SUCCESS",
          :message => "操作成功",
          :data =>
              [
                  {
                      :id => 1,
                      :commissioner =>
                          {
                              :id => 1,
                              :name => nil,
                              :phone_number => "18611979882",
                              :code_image => nil
                          },
                      :content => "this is a test shop promotion log",
                      :created_at => created_at
                  },
                  {
                      :id => 2,
                      :commissioner =>
                          {
                              :id => 1,
                              :name => nil,
                              :phone_number => "18611979882",
                              :code_image => nil
                          },
                      :content => "this is a test shop promotion log",
                      :created_at => created_at
                  }
              ]
      }
    }

    before do
      create(:shop_promotion_log, {c_id: commissioner.id, shop_id: shop.id})
      create(:shop_promotion_log, {c_id: commissioner.id, shop_id: shop.id})
      create(:shop_promotion_log, {c_id: commissioner.id, shop_id: shop.id})
    end

    it "should return commissioner's shop's promotion logs" do
      expect(subject.shop_promotion_logs(commissioner.id, shop.id, 4, 1)[:data].count).to eq 3
      expect(subject.shop_promotion_logs(commissioner.id, shop.id, 2, 2)[:data].count).to eq 1
      expect(subject.shop_promotion_logs(commissioner.id, shop.id, 5, 2)[:data].count).to eq 0
    end

    it "should return shop's promotion logs in correct json format" do
      expect(subject.shop_promotion_logs commissioner.id, shop.id, 2, 1).to eq fake_result
    end
  end

  describe "#personal_QR_code" do
    let(:image) { create(:image) }
    let(:commissioner) { create(:commissioner, code_image: image) }
    let(:fake_result) {
      {
          :status => "SUCCESS",
          :message => "操作成功",
          :image_path => "images/1.jpg"
      }
    }

    it "should return url of commissioner's QR code" do
      expect(subject.personal_QR_code commissioner.id).to eq fake_result
    end
  end

  describe "#register_shop" do
    let(:name) { "new shop" }
    let(:address) { "address1" }
    let(:longitude) { "103.123" }
    let(:latitude) { "103.123" }
    let(:scale) { "middle" }
    let(:category) { "street by" }
    let(:desc) { "magic shop" }
    let(:province) { "shannxi" }
    let(:city) { "xi'an" }
    let(:commissioner) { create(:commissioner, name: "haha") }
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


    it "should create a new shop" do
      subject.register_shop name, address, longitude, latitude, scale, category, desc, commissioner.id, fake_temp_image_paths, province, city
      expect(Pandora::Models::Shop.count).to eq 1
    end


    it "should add shop promotion log" do
      subject.register_shop name, address, longitude, latitude, scale, category, desc, commissioner.id, fake_temp_image_paths, province, city
      expect(Pandora::Models::Commissioner.find(commissioner.id).shop_promotion_logs.count).to eq 1
      expect(Pandora::Models::Commissioner.find(commissioner.id).shop_promotion_logs.first.content).to eq "haha(18611979882)录入店铺new shop的信息"
    end

    context "raise common error" do
      before do
        create(:shop, {name: name, address: address, longitude: longitude, latitude: latitude})
      end

      it "should raise common error if have similar shops in pandora" do
        expect { subject.register_shop name, address, longitude, latitude, scale, category, desc, commissioner.id, fake_temp_image_paths, province, city }.to raise_error Common::Error, "臣妾觉的这家店铺已经被录入了,大王搜索一下看看能找到吗?"
      end
    end
  end

  describe "#delete_shop" do
    let(:commissioner) { create(:commissioner, {name: "haha"}) }

    context "can delete" do
      it "should delete shop if shop has no designers" do
        shop = create(:shop)
        subject.delete_shop commissioner.id, shop.id
        expect(Pandora::Models::Shop.find(shop.id).deleted).to eq true
      end

      it "should add shop promotion log" do
        shop = create(:shop)
        subject.delete_shop commissioner.id, shop.id
        expect(Pandora::Models::Commissioner.find(commissioner.id).shop_promotion_logs.count).to eq 1
        expect(Pandora::Models::Commissioner.find(commissioner.id).shop_promotion_logs.first.content).to eq "haha(18611979882)删除了店铺shop/1"
      end
    end

    context "raise common error" do
      it "should raise error if shop have designers" do
        shop = create(:shop)
        user = create(:user)
        designer = create(:designer, {user: user, shop: shop})
        expect { subject.delete_shop commissioner.id, shop.id }.to raise_error Common::Error, "该店铺已经有关联的设计师,不能被删除!"
      end
    end
  end

  describe "#search_shops" do
    let(:fake_result) {
      {
          :status => "SUCCESS",
          :message => "操作成功",
          :data =>
              [
                  {
                      :id => 1,
                      :name => "shop li",
                      :address => "zhuque street No.2",
                      :latitude => "120.244",
                      :longitude => "288.244"
                  }
              ]
      }
    }

    before do
      create(:shop, name: "shop li")
      create(:shop, name: "shop rui")
      create(:shop, name: "shop cui")
      create(:shop, name: "shop dong")
    end

    it "should return matched shops" do
      expect(subject.search_shops("shop", 5, 1, "created_at")[:data].count).to eq 4
      expect(subject.search_shops("li", 5, 1, "created_at")[:data].count).to eq 1
      expect(subject.search_shops("i", 5, 1, "created_at")[:data].count).to eq 3
    end

    it "should return matched shops info in correct json format" do
      expect(subject.search_shops "li", 5, 1, "created_at").to eq fake_result
    end
  end

  describe "#shops" do
    let(:fake_result) {
      {
          :status => "SUCCESS",
          :message => "操作成功",
          :data =>
              [
                  {
                      :id => 1,
                      :name => "shop/1",
                      :address => "zhuque street No.2",
                      :latitude => "120.244",
                      :longitude => "288.244"
                  },
                  {
                      :id => 2,
                      :name => "shop/1",
                      :address => "zhuque street No.2",
                      :latitude => "120.244",
                      :longitude => "288.244"
                  }
              ]
      }
    }
    before do
      create(:shop)
      create(:shop)
      create(:shop)
      create(:shop)
    end

    it "should return all shops" do
      expect(subject.shops(2, 1, "created_at")[:data].count).to eq 2
      expect(subject.shops(5, 1, "created_at")[:data].count).to eq 4
    end

    it "should return shops info in correct json format" do
      expect(subject.shops 2, 1, "created_at").to eq fake_result
    end
  end

  describe "#shop_all_promotion_logs" do
    let(:shop) { create(:shop) }
    let(:commissioner) { create(:commissioner, {name: "haha"}) }
    let(:fake_result) {
      {
          :status => "SUCCESS",
          :message => "操作成功",
          :data =>
              [
                  {:id => 1,
                   :commissioner =>
                       {
                           :id => 1,
                           :name => "haha",
                           :phone_number => "18611979882",
                           :code_image => nil
                       },
                   :content => "this is a test shop promotion log",
                   :created_at => created_at
                  }
              ]
      }
    }

    before do
      create(:shop_promotion_log, {c_id: commissioner.id, shop_id: shop.id})
      create(:shop_promotion_log, {c_id: commissioner.id, shop_id: shop.id})
      create(:shop_promotion_log, {c_id: commissioner.id, shop_id: shop.id})
    end

    it "should return shop's all promotion logs" do
      expect(subject.shop_all_promotion_logs(shop.id, 4, 1)[:data].count).to eq 3
      expect(subject.shop_all_promotion_logs(shop.id, 1, 1)[:data].count).to eq 1
    end

    it "should return logs info in correct json format" do
      expect(subject.shop_all_promotion_logs shop.id, 1, 1).to eq fake_result
    end
  end

  describe "#add_shop_promotion_log" do
    let(:shop) { create(:shop) }
    let(:commissioner) { create(:commissioner, {name: "haha"}) }

    it "should add shop promotion log" do
      subject.add_shop_promotion_log commissioner.id, shop.id, "this is test shop promotion log"
      expect(Pandora::Models::Commissioner.find(commissioner.id).shop_promotion_logs.count).to eq 1
      expect(Pandora::Models::Shop.find(shop.id).promotion_logs.count).to eq 1
    end
  end
end