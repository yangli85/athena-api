require 'controllers/designer_controller'
require 'pandora/models/twitter'
require 'pandora/models/twitter_image'

describe DesignerController do
  let(:fake_lon) { "108.9420" }
  let(:fake_lat) { "34.2610" }

  before do
    allow_any_instance_of(Pandora::Models::Vita).to receive(:relative_time).and_return("8小时前")
    shop1 = create(:shop, {latitude: '34.2620', longitude: '108.9430', name: 'test1', address: 'address1'})
    shop2 = create(:shop, {latitude: '34.2620', longitude: '108.9440', name: 'test2', address: 'address2'})
    shop3 = create(:shop, {latitude: '34.2320', longitude: '108.9930', name: 'test3', address: 'address3'})
    shop4 = create(:shop, {latitude: '34.2420', longitude: '108.9430', name: 'test4', address: 'address4'})
    shop5 = create(:shop, {latitude: '34.3620', longitude: '108.9630', name: 'test5', address: 'address5'})

    user1 = create(:user, phone_number: '13800000001')
    user2 = create(:user, phone_number: '13800000002')
    user3 = create(:user, phone_number: '13800000003')
    user4 = create(:user, phone_number: '13800000004')
    user5 = create(:user, phone_number: '13800000005')
    user6 = create(:user, phone_number: '13800000006')
    user7 = create(:user, phone_number: '13800000007')

    designer1 = create(:designer, {user: user1, shop: shop1, totally_stars: 5})
    designer2 = create(:designer, {user: user2, shop: shop1, totally_stars: 6})
    designer3 = create(:designer, {user: user3, shop: shop2, totally_stars: 7})
    designer4 = create(:designer, {user: user4, shop: shop2, totally_stars: 8})
    designer5 = create(:designer, {user: user5, shop: shop3, totally_stars: 9})
    designer6 = create(:designer, {user: user6, shop: shop4, totally_stars: 10})
    designer7 = create(:designer, {user: user7, shop: shop5, totally_stars: 11})

    image1 = create(:image)
    image2 = create(:image)
    image3 = create(:image)
    image4 = create(:image)
    image5 = create(:image)
    image6 = create(:image)
    image7 = create(:image)

    s_image1 = create(:image, original_image: image1)
    s_image2 = create(:image, original_image: image2)
    s_image3 = create(:image, original_image: image3)
    s_image4 = create(:image, original_image: image4)
    s_image5 = create(:image, original_image: image5)
    s_image6 = create(:image, original_image: image6)
    s_image7 = create(:image, original_image: image7)

    twitter1 = create(:twitter, {id: 10, author: user1, designer: designer1})
    twitter2 = create(:twitter, {id: 11, author: user2, designer: designer1})
    twitter3 = create(:twitter, {author: user3, designer: designer1})

    twitter_image1 = create(:twitter_image, {image: image1, twitter: twitter1, likes: 10})
    twitter_image2 = create(:twitter_image, {image: image2, twitter: twitter2, likes: 10})
    twitter_image3 = create(:twitter_image, {image: image3, twitter: twitter3, likes: 4, rank: 1})
    twitter_image4 = create(:twitter_image, {image: image4, twitter: twitter3, likes: 8, rank: 2})

    vita1 = create(:vita, designer: designer1)
    vita2 = create(:vita, designer: designer1)
    vita1_image1 = create(:vita_image, {vita: vita1, image: image5})
    vita1_image2 = create(:vita_image, {vita: vita1, image: image6})
    vita2_image1 = create(:vita_image, {vita: vita2, image: image7})
  end
  describe "#get_vicinal_designers" do
    context 'vicinal' do
      it "should return vicinal designers" do
        expect(subject.get_vicinal_designers(fake_lon, fake_lat, 5, 1, 5, 'totally_stars')[:data].count).to eq 5
        expect(subject.get_vicinal_designers(fake_lon, fake_lat, 5, 1, 1, 'totally_stars')[:data].count).to eq 4
      end

      it "should ordered by distance asc" do
        designers = subject.get_vicinal_designers(fake_lon, fake_lat, 5, 1, 5, 'totally_stars')[:data]
        expect(designers.each_cons(2).all? { |d1, d2| d1[:distance] <= d2[:distance] }).to eq true
      end

      it "should ordered by totally_stars desc if have same distance" do
        designers = subject.get_vicinal_designers(fake_lon, fake_lat, 2, 1, 3, 'totally_stars')[:data]
        expect(designers.each_cons(2).all? { |d1, d2| d1[:stars] >= d2[:stars] }).to eq true
      end
    end

    context 'pagination' do
      it "should return designers for current_page" do
        expect(subject.get_vicinal_designers(fake_lon, fake_lat, 5, 1, 5, 'totally_stars')[:data].count).to eq 5
        expect(subject.get_vicinal_designers(fake_lon, fake_lat, 10, 1, 5, 'totally_stars')[:data].count).to eq 6
        expect(subject.get_vicinal_designers(fake_lon, fake_lat, 10, 2, 5, 'totally_stars')[:data].count).to eq 0
        expect(subject.get_vicinal_designers(fake_lon, fake_lat, 5, 2, 5, 'totally_stars')[:data].count).to eq 1
      end
    end

    context 'content' do
      let(:fake_result) {
        {
            :status => "SUCCESS",
            :message => "操作成功",
            :data => [
                {
                    :id => 2,
                    :user_id => 2,
                    :name => "user1",
                    :avatar => nil,
                    :distance => 0.08964233507326207,
                    :stars => 6,
                    :shop =>
                        {
                            :id => 1,
                            :name => "test1",
                            :address => "address1",
                            :latitude => "34.2620",
                            :longitude => "108.9430"
                        }
                },
                {
                    :id => 1,
                    :user_id => 1,
                    :name => "user1",
                    :avatar => nil,
                    :distance => 0.08964233507326207,
                    :stars => 5,
                    :shop =>
                        {
                            :id => 1,
                            :name => "test1",
                            :address => "address1",
                            :latitude => "34.2620",
                            :longitude => "108.9430"
                        }
                }
            ]
        }
      }
      it "should retrun correct details for each designer in json format" do
        expect(subject.get_vicinal_designers(fake_lon, fake_lat, 2, 1, 3, 'totally_stars')).to eq fake_result
      end
    end
  end

  describe "#get_ordered_designers" do
    let(:fake_result) {
      {
          :status => "SUCCESS",
          :message => "操作成功",
          :data => [
              {
                  :id => 7,
                  :user_id => 7,
                  :name => "user1",
                  :avatar => nil,
                  :stars => 11,
                  :shop =>
                      {
                          :id => 5,
                          :name => "test5",
                          :address => "address5",
                          :latitude => "34.3620",
                          :longitude => "108.9630"
                      }
              },
              {
                  :id => 6,
                  :user_id => 6,
                  :name => "user1",
                  :avatar => nil,
                  :stars => 10,
                  :shop =>
                      {
                          :id => 4,
                          :name => "test4",
                          :address => "address4",
                          :latitude => "34.2420",
                          :longitude => "108.9430"
                      }
              }
          ]
      }
    }

    it "should return designers for current_page" do
      expect(subject.get_ordered_designers(5, 1, 'totally_stars')[:data].count).to eq 5
      expect(subject.get_ordered_designers(5, 2, 'totally_stars')[:data].count).to eq 2
      expect(subject.get_ordered_designers(10, 1, 'totally_stars')[:data].count).to eq 7
      expect(subject.get_ordered_designers(10, 2, 'totally_stars')[:data].count).to eq 0
    end

    it "should order designers by totally stars" do
      designers = subject.get_ordered_designers(10, 1, 'totally_stars')[:data]
      expect(designers.each_cons(2).all? { |d1, d2| d1[:stars] >= d2[:stars] }).to eq true
    end

    it "should return designers data in correct json format" do
      expect(subject.get_ordered_designers 2, 1, 'totally_stars').to eq fake_result
    end
  end

  describe "#get_designer_info" do
    let(:fake_result) {
      {
          :status => "SUCCESS",
          :message => "操作成功",
          :data =>
              {
                  :id => 1,
                  :user_id => 1,
                  :name => "user1",
                  :avatar => nil,
                  :shop =>
                      {
                          :id => 1,
                          :name => "test1",
                          :address => "address1",
                          :latitude => "34.2620",
                          :longitude => "108.9430"
                      },
                  :gender => "unknow",
                  :stars => 5,
                  :rank => 7,
                  :phone_number => "13800000001"
              }
      }
    }
    it "should return designer info in correct json format" do
      expect(subject.get_designer_info 1).to eq fake_result
    end
  end

  describe "#get_designer_works" do
    let(:fake_result) {
      {
          :status => "SUCCESS",
          :message => "操作成功",
          :data =>
              [
                  {
                      :image => {
                          :id => 1,
                          :url => "images/1.jpg",
                          :s_url => "images/1.jpg"
                      },
                      :likes => 10,
                      :designer =>
                          {
                              :id => 1,
                              :user_id => 1,
                              :name => "user1",
                              :avatar => nil
                          },
                      :twitter_id => 10,
                      :rank => 1
                  },
                  {
                      :image => {
                          :id => 2,
                          :url => "images/1.jpg",
                          :s_url => "images/1.jpg"
                      },
                      :likes => 10,
                      :designer =>
                          {
                              :id => 1,
                              :user_id => 1,
                              :name => "user1",
                              :avatar => nil
                          },
                      :twitter_id => 11,
                      :rank => 1
                  }
              ]
      }
    }
    it "should return designer's works for current page" do
      expect(subject.get_designer_works(1, 5, 1)[:data].count).to eq 3
      expect(subject.get_designer_works(1, 2, 1)[:data].count).to eq 2
      expect(subject.get_designer_works(1, 2, 2)[:data].count).to eq 1
      expect(subject.get_designer_works(1, 5, 2)[:data].count).to eq 0
    end

    it 'should return the works in correct json format' do
      expect(subject.get_designer_works(1, 2, 1)).to eq (fake_result)
    end

    it 'should return the most favorite image for each twitter' do
      Pandora::Models::Twitter.where(id: [10, 11]).destroy_all
      expect(subject.get_designer_works(1, 2, 1)[:data].first[:likes]).to eq 8
      expect(subject.get_designer_works(1, 2, 1)[:data].first[:rank]).to eq 2
    end
  end

  describe "#get_designer_vitae" do
    let(:fake_result) {
      {
          :status => "SUCCESS",
          :message => "操作成功",
          :data => [
              {
                  :id => 1,
                  :desc => "this is a test vita",
                  :images => [
                      {
                          :id => 5,
                          :url => "images/1.jpg",
                          :s_url => "images/1.jpg"
                      },
                      {
                          :id => 6,
                          :url => "images/1.jpg",
                          :s_url => "images/1.jpg"
                      }
                  ],
                  :created_at => "8小时前"
              },
              {
                  :id => 2,
                  :desc => "this is a test vita",
                  :images => [
                      {
                          :id => 7,
                          :url => "images/1.jpg",
                          :s_url => "images/1.jpg"
                      }
                  ],
                  :created_at => "8小时前"
              }
          ]
      }
    }
    it "should return current page's designer's vitae" do
      expect(subject.get_designer_vitae(1, 2, 1)[:data].count).to eq 2
      expect(subject.get_designer_vitae(1, 5, 1)[:data].count).to eq 2
      expect(subject.get_designer_vitae(1, 5, 2)[:data].count).to eq 0
    end

    it "should return desiger's vita in correct json format" do
      expect(subject.get_designer_vitae 1, 2, 1).to eq fake_result
    end
  end

  describe "#search_designers" do
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
                      :shop =>
                          {
                              :id => 1,
                              :name => "test1",
                              :address => "address1",
                              :latitude => "34.2620",
                              :longitude => "108.9430"
                          },
                      :stars => 5
                  }
              ]
      }
    }

    it "should return matched designers" do
      expect(subject.search_designers(10, 1, 'user1')[:data].count).to eq 7
      expect(subject.search_designers(10, 1, '13800000001')[:data].count).to eq 1
      expect(subject.search_designers(10, 1, '138')[:data].count).to eq 7
    end

    it "should return matched designers in correct json format" do
      expect(subject.search_designers(10, 1, '13800000001')).to eq fake_result
    end
  end

  describe "#get_designer_rank" do
    let(:fake_result) {
      {
          :status => "SUCCESS",
          :message => "操作成功",
          :data => {
              :rank => 1
          }
      }
    }
    before do
      new_user = create(:user, {phone_number: '13888888888'})
      create(:designer, {user: new_user, totally_stars: 100, is_vip: false})
    end

    it "should return designer rank in all current vip users" do
      expect(subject.get_designer_rank(7, "totally_stars")[:data][:rank]).to eq 1
      expect(subject.get_designer_rank(6, "totally_stars")[:data][:rank]).to eq 2
    end

    it "should return designer rank in correct json format" do
      expect(subject.get_designer_rank(7, "totally_stars")).to eq fake_result
    end
  end

  describe "#get_designer_details" do
    let(:fake_result) {
      {
          :status => "SUCCESS",
          :message => "操作成功",
          :data =>
              {
                  :id => 1,
                  :user_id => 1,
                  :name => "user1",
                  :avatar => nil,
                  :vitality => 100,
                  :gender => "unknow",
                  :new_message => 0,
                  :balance => nil,
                  :twitters => 3,
                  :phone_number => "13800000001",
                  :shop =>
                      {
                          :id => 1,
                          :name => "test1",
                          :address => "address1",
                          :latitude => "34.2620",
                          :longitude => "108.9430"
                      },
                  :vitae_count => 2
              }
      }
    }
    it "should return designer's details in correct json format" do
      expect(subject.get_designer_details 1).to eq (fake_result)
    end

    it "should raise common error if designer not exist" do
      expect { subject.get_designer_details 100 }.to raise_error Common::Error, "设计师不存在."
    end
  end

  describe "designer twitter" do
    let(:user) { create(:user) }
    let(:author) { create(:user, phone_number: '13812345678') }
    let(:designer) { create(:designer, user: user) }
    let(:image) { create(:image) }
    let(:fake_result) {
      {
          :status => "SUCCESS",
          :message => "操作成功",
          :data =>
              [
                  {
                      :id => 13,
                      :author =>
                          {
                              :id => 8,
                              :name => "user1",
                              :avatar => nil
                          },
                      :content => "this is a test twitter",
                      :likes => 20,
                      :designer =>
                          {
                              :id => 8,
                              :user_id => 9,
                              :name => "user1",
                              :avatar => nil
                          },
                      :image_count => 1,
                      :images => [
                          {
                              :image =>
                                  {
                                      :id => 15,
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
      create(:image, original_image: image)
      allow_any_instance_of(Pandora::Models::Twitter).to receive(:relative_time).and_return("1小时前")
      twitter = create(:twitter, author: author, designer: designer)
      create(:twitter_image, {twitter: twitter, image: image})
    end

    describe "#get_designer_twitters" do
      it "should return designer's twitters" do
        expect(subject.get_designer_twitters(designer.id, 1, 1)[:data].count).to eq 1
      end

      it "should return designer's twitters in correct json format" do
        expect(subject.get_designer_twitters(designer.id, 1, 1)).to eq fake_result
      end
    end

    describe "#delete_twitter" do
      it "should return delete user's twitters" do
        subject.delete_twitter(designer.id, designer.twitters.first.id)
        expect(Pandora::Models::Designer.find(designer.id).twitters.active.count).to eq 0
      end
    end

    describe "#designer_latest_customers" do
      let(:fake_result) {
        {
            :status => "SUCCESS",
            :message => "操作成功",
            :data =>
                [
                    {
                        :id => 8,
                        :name => "user1",
                        :avatar => nil,
                        :phone_number => "13812345678"
                    }
                ]
        }
      }

      before do
        create(:twitter, author: author, designer: designer)
      end

      it "should return designer's latest customers in correct json format" do
        expect(subject.designer_latest_customers designer.id).to eq fake_result
      end
    end
  end

  describe "designer shop" do
    let(:user) { create(:user) }
    let(:designer) { create(:designer, user: user) }
    let(:fake_name) { "new shop" }
    let(:fake_address) { "ZhuQue Street No1" }
    let(:fake_lat) { "108.124" }
    let(:fake_lon) { "108.124" }

    describe "#update_new_shop" do
      it "should create a new shop and update designer'shop" do
        subject.update_new_shop fake_name, fake_address, fake_lat, fake_lon, designer.id
        expect(Pandora::Models::Designer.find(designer.id).shop.attributes).to eq (
                                                                                      {
                                                                                          :id => 6,
                                                                                          :name => fake_name,
                                                                                          :address => fake_address,
                                                                                          :latitude => fake_lat,
                                                                                          :longitude => fake_lon
                                                                                      }
                                                                                  )
      end
    end

    describe "#update_shop" do
      it "should update designer's shop" do
        subject.update_shop designer.id, 5
        expect(Pandora::Models::Designer.find(designer.id).shop.id).to eq 5
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
                        :name => "test1",
                        :address => "address1",
                        :latitude => "34.2620",
                        :longitude => "108.9430"
                    }
                ]
        }
      }

      it "should matched shops" do
        expect(subject.search_shops('test')[:data].count).to eq 5
        expect(subject.search_shops('test1')[:data].count).to eq 1
        expect(subject.search_shops('nononono')[:data].count).to eq 0
      end

      it "should return shops in correct json format" do
        expect(subject.search_shops 'test1').to eq fake_result
      end
    end
  end

  describe "#create_vita" do
    let(:user) { create(:user) }
    let(:designer) { create(:designer, user: user) }
    let(:fake_images_folder) { "temp_images" }
    let(:fake_temp_images_folder) { "spec/temp_images" }
    let(:fake_temp_image_paths) { ["#{fake_temp_images_folder}/icon.jpg", "#{fake_temp_images_folder}/icon.png"] }
    let(:fake_image_paths) { ["spec/fixtures/icon.jpg", "spec/fixtures/icon.png"] }
    let(:fake_desc) { "this is a test vita" }

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

    it "should create a new vita" do
      subject.create_vita fake_desc, fake_temp_image_paths, designer.id
      expect(Pandora::Models::Designer.find(designer.id).vitae.count).to eq 1
    end

    it "should generate small image for upload images" do
      allow_any_instance_of(Pandora::Services::DesignerService).to receive(:create_vita)
      allow(File).to receive(:delete)
      subject.create_vita fake_desc, fake_temp_image_paths, designer.id
      fake_temp_image_paths.each do |path|
        expect(File.exist?(Common::ImageHelper.new.generate_s_image_path path)).to eq true
      end
    end

    it "should move image from temp folder to vita folder" do
      subject.create_vita fake_desc, fake_temp_image_paths, designer.id
      expect(Dir["#{fake_temp_images_folder}/*"].length).to eq 0
      expect(Dir["#{fake_images_folder}/vita/*"].length).to eq 4
    end

    it "should delete temp file if raise error when create twitter" do
      allow_any_instance_of(Pandora::Services::DesignerService).to receive(:create_vita).and_raise StandardError
      expect { subject.create_vita fake_desc, fake_temp_image_paths, designer.id }.to raise_error StandardError
      expect(Dir["#{fake_temp_images_folder}/*"].length).to eq 0
    end

    it "should create a new vita" do
      subject.create_vita fake_desc, fake_temp_image_paths, designer.id
      vita = Pandora::Models::Designer.find(designer.id).vitae.first
      expect(vita.images.map(&:s_url)).to eq (["temp_images/vita/s_icon.jpg", "temp_images/vita/s_icon.png"])
      expect(vita.images.map(&:url)).to eq (["temp_images/vita/icon.jpg", "temp_images/vita/icon.png"])
      expect(vita.designer).to eq designer
      expect(vita.desc).to eq fake_desc
    end
  end

  describe "#delete_vita" do
    let(:user) { create(:user, phone_number: '13800001111') }
    let(:designer) { create(:designer, user: user) }

    before do
      image1 = create(:image)
      image2 = create(:image)
      image3 = create(:image)
      image4 = create(:image)
      s_image1 = create(:image, original_image: image1)
      s_image2 = create(:image, original_image: image2)
      s_image3 = create(:image, original_image: image3)
      s_image4 = create(:image, original_image: image4)
      vita1 = create(:vita, designer: designer)
      vita2 = create(:vita, designer: designer)
      vita3 = create(:vita, designer: designer)
      vita4 = create(:vita, designer: designer)
      create(:vita_image, {image: image1, vita: vita1})
      create(:vita_image, {image: image2, vita: vita2})
      create(:vita_image, {image: image3, vita: vita3})
      create(:vita_image, {image: image4, vita: vita4})
    end

    it "should delete single vita" do
      subject.delete_vitae designer.vitae.first.id
      expect(Pandora::Models::Designer.find(designer.id).vitae.count).to eq 3
    end

    it "should delete muiltiple vitae" do
      subject.delete_vitae designer.vitae.map(&:id)
      expect(Pandora::Models::Designer.find(designer.id).vitae.count).to eq 0
    end
  end

  describe "#pay_for_vip" do
    let(:user) { create(:user, phone_number: '13800001111') }
    let(:designer) { create(:designer, user: user) }

    context "not a vip user" do
      let(:fake_today) { DateTime.parse("201512121212") }
      let(:fake_expired_at) { DateTime.parse("201612121212") }

      before do
        allow(DateTime).to receive(:now).and_return fake_today
        designer.update(is_vip: false)
      end

      it "should update designer expired time" do
        subject.pay_for_vip designer.id
        expect(Pandora::Models::Designer.find(designer.id).expired_at).to eq fake_expired_at
      end

      it "should update designer to be vip user" do
        subject.pay_for_vip designer.id
        expect(Pandora::Models::Designer.find(designer.id).is_vip).to be true
      end
    end

    context "not a vip user" do
      let(:fake_expired_at) { DateTime.parse("201512121212") }
      let(:fake_new_expired_at) { DateTime.parse("201612121212") }

      before do
        designer.update(expired_at: fake_expired_at)
      end

      it "should update designer expired time" do
        subject.pay_for_vip designer.id
        expect(Pandora::Models::Designer.find(designer.id).expired_at).to eq fake_new_expired_at
      end
    end
  end
end