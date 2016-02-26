require 'controllers/ad_controller'
require 'pandora/models/image'
require 'pandora/models/ad_image'

describe AdController do
  describe '#get_ad_images' do
    let(:fake_category) { 'index' }
    before do
      image1 =create(:image, {url: 'images/1.jpg', category: 'ad'})
      image2 =create(:image, {url: 'images/2.jpg', category: 'ad'})
      image3 =create(:image, {url: 'images/3.jpg', category: 'ad'})
      create(:ad_image, {image: image1, category: 'index', event: 'search_designer', args: {designer_id: 1}})
      create(:ad_image, {image: image2, category: 'index', event: 'search_designer', args: {designer_id: 2}})
      create(:ad_image, {image: image3, category: 'banner', event: 'search_designer', args: {designer_id: 3}})
    end

    it "should return all ad images for the given category" do
      expect(subject.get_ad_images fake_category).to eq(
                                                         {
                                                             status: 'SUCCESS',
                                                             message: "操作成功",
                                                             data:
                                                                 [
                                                                     {
                                                                         :image => {
                                                                             :id => 1,
                                                                             :url => "images/1.jpg",
                                                                             :s_url => nil
                                                                         },
                                                                         :event => "search_designer",
                                                                         :args => "{:designer_id=>1}"
                                                                     },
                                                                     {
                                                                         :image => {
                                                                             :id => 2,
                                                                             :url => "images/2.jpg",
                                                                             :s_url => nil
                                                                         },
                                                                         :event => "search_designer",
                                                                         :args => "{:designer_id=>2}"
                                                                     }
                                                                 ]
                                                         }
                                                     )
    end

    it "should return empty array if no image for given category" do
      expect(subject.get_ad_images 'wrong category').to eq (
                                                               {
                                                                   status: 'SUCCESS',
                                                                   message: "操作成功",
                                                                   data: []
                                                               }
                                                           )
    end
  end
end