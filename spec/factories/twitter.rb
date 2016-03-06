FactoryGirl.define do
  factory :twitter, :class => 'Pandora::Models::Twitter' do
    content 'this is a test twitter'
    latitude '301.355'
    longitude '210.124'
    image_count 1
    deleted false
    stars 4
  end
end