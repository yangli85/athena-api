FactoryGirl.define do
  sequence(:out_trade_no) { |n| n }

  factory :payment_log, :class => 'Pandora::Models::PaymentLog' do
    out_trade_no FactoryGirl.generate(:out_trade_no)
  end
end