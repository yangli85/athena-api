FactoryGirl.define do
  sequence(:account_id) { |n| n }

  factory :account_log, :class => 'Pandora::Models::AccountLog' do
    account_id FactoryGirl.generate(:account_id)
    balance 10
    event 'donate'
    channel 'alipay'
    from_user FactoryGirl.generate(:user_id)
    to_user FactoryGirl.generate(:user_id)
  end
end