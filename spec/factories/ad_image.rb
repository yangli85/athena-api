FactoryGirl.define do
  factory :ad_image, :class => 'Pandora::Models::AdImage' do
    category 'index'
    event 'designer'
    args "{designer_id: 1}"
  end
end