FactoryGirl.define do
  factory :message, :class => 'Pandora::Models::Message' do
    content "this is a test message"
    is_new true
  end
end