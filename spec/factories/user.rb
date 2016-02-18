FactoryGirl.define do
  sequence(:identity) { |n| n }

  factory :user, :class => 'Pandora::Models::User' do
    name "user#{FactoryGirl.generate(:identity)}"
    gender 'unknow'
    phone_number '13800000000'
    vitality 100
  end
end