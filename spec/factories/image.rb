FactoryGirl.define do
  sequence(:image_name) { |n| n }

  factory :image, :class => 'Pandora::Models::Image' do
    category 'avatar'
    url "images/#{FactoryGirl.generate(:image_name)}.jpg"
    height 1000
    width 500
  end
end