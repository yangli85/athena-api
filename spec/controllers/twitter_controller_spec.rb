require 'controllers/twitter_controller'
require 'date'

describe TwitterController do
  before do
    allow_any_instance_of(Pandora::Models::Twitter).to receive(:relative_time).and_return("8小时前")
    avatar = create(:image)
    user = create(:user, avatar: avatar)
    designer = create(:designer, user: user)
    s_image1 = create(:image)
    s_image2 = create(:image)
    s_image3 = create(:image)
    s_image4 = create(:image)
    image1 = create(:image, s_image: s_image1)
    image2 = create(:image, s_image: s_image2)
    image3 = create(:image, s_image: s_image3)
    image4 = create(:image, s_image: s_image4)
    twitter1 = create(:twitter, {author: user, designer: designer})
    twitter2 = create(:twitter, {author: user, designer: designer, image_count: 3})
    create(:twitter_image, {twitter: twitter1, image: image1, likes: 3})
    create(:twitter_image, {twitter: twitter2, rank: 1, image: image2, likes: 4})
    create(:twitter_image, {twitter: twitter2, rank: 2, image: image3, likes: 5})
    create(:twitter_image, {twitter: twitter2, rank: 3, image: image4, likes: 6})
  end

  describe "#get_ordered_twitter_images" do
    let(:fake_result) {
      {
          status: 'SUCCESS',
          message: '操作成功',
          data: [
              {
                  :image => {
                      :id => 9,
                      :url => "images/1.jpg",
                      :s_url => "images/1.jpg"
                  },
                  :likes => 6,
                  :designer => {
                      :id => 1,
                      :user_id => 1,
                      :name => "user1",
                      :avatar => {
                          :id => 1,
                          :url => "images/1.jpg",
                          :s_url => nil
                      }
                  },
                  :twitter_id => 2,
                  :rank => 3
              },
              {
                  :image => {
                      :id => 8,
                      :url => "images/1.jpg",
                      :s_url => "images/1.jpg"
                  },
                  :likes => 5,
                  :designer =>
                      {
                          :id => 1,
                          :user_id => 1,
                          :name => "user1",
                          :avatar => {
                              :id => 1,
                              :url => "images/1.jpg",
                              :s_url => nil
                          }
                      },
                  :twitter_id => 2,
                  :rank => 2
              },
              {
                  :image => {
                      :id => 7,
                      :url => "images/1.jpg",
                      :s_url => "images/1.jpg"
                  },
                  :likes => 4,
                  :designer => {
                      :id => 1,
                      :user_id => 1,
                      :name => "user1",
                      :avatar => {
                          :id => 1,
                          :url => "images/1.jpg",
                          :s_url => nil
                      }
                  },
                  :twitter_id => 2,
                  :rank => 1
              },
              {
                  :image => {
                      :id => 6,
                      :url => "images/1.jpg",
                      :s_url => "images/1.jpg"
                  },
                  :likes => 3,
                  :designer => {
                      :id => 1,
                      :user_id => 1,
                      :name => "user1",
                      :avatar => {
                          :id => 1,
                          :url => "images/1.jpg",
                          :s_url => nil
                      }
                  },
                  :twitter_id => 1,
                  :rank => 1
              }
          ]
      }
    }
    it "should return ordered twitter images in json format" do
      expect(subject.get_ordered_twitter_images 5, 1, 'likes').to eq fake_result
    end
  end

  describe "#get_twitter_images" do
    let(:fake_twitter_id) { 2 }
    let(:fake_result) {
      {
          :status => "SUCCESS",
          :message => '操作成功',
          :data => {
              :id => 2,
              :author =>
                  {
                      :id => 1,
                      :name => "user1",
                      :avatar => {
                          :id => 1,
                          :url => "images/1.jpg",
                          :s_url => nil
                      }
                  },
              :content => "this is a test twitter",
              :likes => 15,
              :designer =>
                  {
                      :id => 1,
                      :user_id => 1,
                      :name => "user1",
                      :avatar => {
                          :id => 1,
                          :url => "images/1.jpg",
                          :s_url => nil
                      }
                  },
              :image_count => 3,
              :images => [
                  {
                      :image => {
                          :id => 7,
                          :url => "images/1.jpg",
                          :s_url => "images/1.jpg"
                      },
                      :likes => 4,
                      :rank => 1
                  },
                  {
                      :image => {
                          :id => 8,
                          :url => "images/1.jpg",
                          :s_url => "images/1.jpg"
                      },
                      :likes => 5,
                      :rank => 2
                  },
                  {
                      :image => {
                          :id => 9,
                          :url => "images/1.jpg",
                          :s_url => "images/1.jpg"
                      },
                      :likes => 6,
                      :rank => 3
                  }
              ],
              :created_at => "8小时前"
          }
      }
    }

    it "should return all twitter's images in json format" do
      expect(subject.get_twitter_images fake_twitter_id).to eq fake_result
    end

    it "should return empty if the twitter not exist" do
      expect(subject.get_twitter_images 100).to eq fake_result.merge({data: nil})
    end
  end

  describe "#get_ordered_twitters" do
    let(:fake_result) {
      {
          :status => "SUCCESS",
          :message => '操作成功',
          :data =>
              [
                  {
                      :id => 1,
                      :author =>
                          {
                              :id => 1,
                              :name => "user1",
                              :avatar => {
                                  :id => 1,
                                  :url => "images/1.jpg",
                                  :s_url => nil
                              }
                          },
                      :content => "this is a test twitter",
                      :likes => 3,
                      :designer =>
                          {
                              :id => 1,
                              :user_id => 1,
                              :name => "user1",
                              :avatar => {
                                  :id => 1,
                                  :url => "images/1.jpg",
                                  :s_url => nil
                              }
                          },
                      :image_count => 1,
                      :images =>
                          [
                              {
                                  :image => {
                                      :id => 6,
                                      :url => "images/1.jpg",
                                      :s_url => "images/1.jpg"
                                  },
                                  :likes => 3,
                                  :rank => 1
                              }
                          ],
                      :created_at => "8小时前"
                  },
                  {
                      :id => 2,
                      :author =>
                          {
                              :id => 1,
                              :name => "user1",
                              :avatar => {
                                  :id => 1,
                                  :url => "images/1.jpg",
                                  :s_url => nil
                              }
                          },
                      :content => "this is a test twitter",
                      :likes => 15,
                      :designer =>
                          {
                              :id => 1,
                              :user_id => 1,
                              :name => "user1",
                              :avatar => {
                                  :id => 1,
                                  :url => "images/1.jpg",
                                  :s_url => nil
                              }
                          },
                      :image_count => 3,
                      :images => [
                          {
                              :image => {
                                  :id => 7,
                                  :url => "images/1.jpg",
                                  :s_url => "images/1.jpg"
                              },
                              :likes => 4,
                              :rank => 1
                          },
                          {
                              :image => {
                                  :id => 8,
                                  :url => "images/1.jpg",
                                  :s_url => "images/1.jpg"
                              },
                              :likes => 5,
                              :rank => 2
                          },
                          {
                              :image => {
                                  :id => 9,
                                  :url => "images/1.jpg",
                                  :s_url => "images/1.jpg"
                              },
                              :likes => 6,
                              :rank => 3
                          }
                      ],
                      :created_at => "8小时前"
                  }
              ]
      }
    }
    it "should return ordered twitters details in json format" do
      expect(subject.get_ordered_twitters 2, 1, "created_at").to eq (fake_result)
    end
  end

  describe "#search_twitter_by_id" do
    let(:fake_result) {
      {
          :status => "SUCCESS",
          :message => '操作成功',
          :data =>
              {
                  :id => 1,
                  :author =>
                      {
                          :id => 1,
                          :name => "user1",
                          :avatar => {
                              :id => 1,
                              :url => "images/1.jpg",
                              :s_url => nil
                          }
                      },
                  :content => "this is a test twitter",
                  :likes => 3,
                  :designer =>
                      {
                          :id => 1,
                          :user_id => 1,
                          :name => "user1",
                          :avatar => {
                              :id => 1,
                              :url => "images/1.jpg",
                              :s_url => nil
                          }
                      },
                  :image_count => 1,
                  :images => [
                      {
                          :image => {
                              :id => 6,
                              :url => "images/1.jpg",
                              :s_url => "images/1.jpg"
                          },
                          :likes => 3,
                          :rank => 1
                      }
                  ],
                  :created_at => "8小时前"
              }
      }
    }
    it "should return matched twitter" do
      expect(subject.search_twitter_by_id 1).to eq (fake_result)
    end

    it "should return nil" do
      expect(subject.search_twitter_by_id 100).to eq (fake_result.merge({data: nil}))
    end
  end
end