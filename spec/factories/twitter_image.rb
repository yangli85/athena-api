FactoryGirl.define do
  factory :twitter_image, :class => 'Pandora::Models::TwitterImage' do
    likes 20
    rank 1
  end
end