FactoryGirl.define do
  sequence(:user_id) { |n| n }

  factory :account, :class => 'Pandora::Models::Account' do
    user_id FactoryGirl.generate(:user_id)
    balance 10
  end
end