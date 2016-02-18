require 'controllers/designer_controller'
require 'pandora/models/twitter'
require 'pandora/models/twitter_image'

describe DesignerController do
  let(:fake_lon) { "108.9420" }
  let(:fake_lat) { "34.2610" }

  before do
    allow_any_instance_of(Pandora::Models::Vita).to receive(:relative_time).and_return("8小时前")
    shop1 = create(:shop, {latitude: '34.2620', longtitude: '108.9430', name: 'test1', address: 'address1'})
    shop2 = create(:shop, {latitude: '34.2620', longtitude: '108.9440', name: 'test2', address: 'address2'})
    shop3 = create(:shop, {latitude: '34.2320', longtitude: '108.9930', name: 'test3', address: 'address3'})
    shop4 = create(:shop, {latitude: '34.2420', longtitude: '108.9430', name: 'test4', address: 'address4'})
    shop5 = create(:shop, {latitude: '34.3620', longtitude: '108.9630', name: 'test5', address: 'address5'})

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

    twitter1 = create(:twitter, {id: 10, author: user1, designer: designer1})
    twitter2 = create(:twitter, {id: 11, author: user2, designer: designer1})
    twitter3 = create(:twitter, {author: user3, designer: designer1})

    twitter_image1 = create(:twitter_image, {image: image1, s_image: image1, twitter: twitter1, likes: 10})
    twitter_image2 = create(:twitter_image, {image: image2, s_image: image2, twitter: twitter2, likes: 10})
    twitter_image3 = create(:twitter_image, {image: image3, s_image: image3, twitter: twitter3, likes: 4, rank: 1})
    twitter_image4 = create(:twitter_image, {image: image4, s_image: image4, twitter: twitter3, likes: 8, rank: 2})

    vita1 = create(:vita, designer: designer1)
    vita2 = create(:vita, designer: designer1)
    vita1_image1 = create(:vita_image, {vita: vita1, image: image1, s_image: image1})
    vita1_image2 = create(:vita_image, {vita: vita1, image: image2, s_image: image2})
    vita2_image1 = create(:vita_image, {vita: vita2, image: image3, s_image: image3})
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
                            :longtitude => "108.9430"
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
                            :longtitude => "108.9430"
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
                          :longtitude => "108.9630"
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
                          :longtitude => "108.9430"
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
                          :longtitude => "108.9430"
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
          :data =>
              [
                  {
                      :s_image => "images/1.jpg",
                      :image => "images/1.jpg",
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
                      :s_image => "images/1.jpg",
                      :image => "images/1.jpg",
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
          :data => [
              {
                  :id => 1,
                  :desc => "this is a test vita",
                  :images =>
                      [
                          {
                              :s_image => "images/1.jpg",
                              :image => "images/1.jpg"
                          },
                          {
                              :s_image => "images/1.jpg",
                              :image => "images/1.jpg"
                          }
                      ],
                  :created_at => "8小时前"
              },
              {
                  :id => 2,
                  :desc => "this is a test vita",
                  :images =>
                      [
                          {
                              :s_image => "images/1.jpg",
                              :image => "images/1.jpg"
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
end