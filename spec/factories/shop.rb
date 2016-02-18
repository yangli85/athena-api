FactoryGirl.define do
  sequence(:shop_name) { |n| n }

  factory :shop, :class => 'Pandora::Models::Shop' do
    name "shop/#{FactoryGirl.generate(:shop_name)}"
    address "zhuque street No.#{FactoryGirl.generate(:shop_name)}"
    latitude '120.244'
    longtitude '288.244'
    scale "M"
    category "apartment"
  end
end
