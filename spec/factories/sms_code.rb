# encoding: UTF-8
FactoryGirl.define do
  phone_number = rand.to_s[2..12]
  code = rand.to_s[2..5]
  factory :sms_code, :class => 'Pandora::Models::SMSCode' do
    phone_number phone_number
    code code
  end
end