FactoryGirl.define do
  factory :designer, :class => 'Pandora::Models::Designer' do
    is_vip true
    expired_at '2015-12-12'
    totally_stars 3
    monthly_stars 3
    weekly_stars 3
    likes 3
  end
end