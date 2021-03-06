FactoryGirl.define do
  factory :order, :class => 'Pandora::Models::Order' do
    product :VIP
    count 10
    total_fee 100
    user_id FactoryGirl.generate(:user_id)
  end
end