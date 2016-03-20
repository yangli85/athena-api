#encoding:utf-8
require 'pandora/models/user'
require 'pandora/models/image'
require 'pandora/models/account'
require 'pandora/models/account_log'
require 'pandora/models/designer'
require 'pandora/models/shop'
require 'pandora/models/ad_image'
require 'pandora/models/twitter'
require 'pandora/models/twitter_image'
require 'pandora/models/favorite_designer'
require 'pandora/models/favorite_image'
require 'pandora/models/vita'
require 'pandora/models/vita_image'
require 'pandora/models/message'
require 'date'

#create_avatar_images (id:1...20)
10.times do |n|
  Pandora::Models::Image.create({
                                    id: n+1,
                                    category: 'avatar',
                                    url: "images/avatar/#{n+1}.jpg"
                                })
end
10.times do |n|
  Pandora::Models::Image.create({
                                    id: n+11,
                                    category: 'avatar',
                                    url: "images/avatar/s_#{n+1}.jpg",
                                    original_image_id: n+1
                                })
end
#create_twitter_images id(:21...40)
10.times do |n|
  Pandora::Models::Image.create({
                                    id: n+21,
                                    category: 'twitter',
                                    url: "images/twitter/#{n+1}.jpg"
                                })
end
10.times do |n|
  Pandora::Models::Image.create({
                                    id: n+31,
                                    category: 'twitter',
                                    url: "images/twitter/s_#{n+1}.jpg",
                                    original_image_id: n+21
                                })
end
#create_vita_images id(41...60)
10.times do |n|
  Pandora::Models::Image.create({
                                    id: n+41,
                                    category: 'vita',
                                    url: "images/vita/#{n+1}.jpg"
                                })
end
10.times do |n|
  Pandora::Models::Image.create({
                                    id: n+51,
                                    category: 'twitter',
                                    url: "images/vita/s_#{n+1}.jpg",
                                    original_image_id: n+41
                                })
end
#create_ad_images id(:61...80)
10.times do |n|
  Pandora::Models::Image.create({
                                    id: n+61,
                                    category: 'ad',
                                    url: "images/ad/#{n+1}.jpg"
                                })
end
10.times do |n|
  Pandora::Models::Image.create({
                                    id: n+71,
                                    category: 'ad',
                                    url: "images/ad/s_#{n+1}.jpg",
                                    original_image_id: n+61
                                })
end
#create_users
10.times do |n|
  Pandora::Models::User.create({
                                   id: n+1,
                                   name: "用户#{n+1}",
                                   gender: [:male, :female, :unknow][n%3],
                                   phone_number: "1380000000#{n}",
                                   image_id: n+1,
                                   vitality: n+100,
                                   status: 'normal'
                               })
end
#create_accounts
10.times do |n|
  Pandora::Models::Account.create({
                                      id: n+1,
                                      user_id: n+1,
                                      balance: n%5
                                  })
end
#create_account_logs
100.times do |n|
  Pandora::Models::AccountLog.create({
                                         id: n+1,
                                         account_id: 1 + (n%10),
                                         balance: 1 + (n%5),
                                         event: [:donate, :recharge, :consume, :unknow][n%4],
                                         channel: [:alipay, :wechat, :beautyshow][n%4],
                                         from_user: 1 + (n%10),
                                         to_user: 10 - (n%10),
                                         desc: "这是用来测试的账户日志.不是很准确!"
                                     })
end
#create_shops
3.times do |n|
  Pandora::Models::Shop.create({
                                   id: n+1,
                                   name: "美发店#{n+1}",
                                   address: "朱雀大街#{n+1}号",
                                   latitude: "34.2#{n}",
                                   longitude: "108.9#{n}",
                                   province: "陕西省",
                                   city: "西安市",
                                   scale: ["大", "中", "小"][n%3],
                                   desc: "这是一个用来测试的美发店"
                               })
end
#create_ad_images
10.times do |n|
  Pandora::Models::AdImage.create({
                                      id: n+1,
                                      category: ['index', "banner"][n%2],
                                      image_id: n+61,
                                      event: 'click',
                                      args: ''
                                  })
end
#create_designers
5.times do |n|
  Pandora::Models::Designer.create({
                                       id: n+1,
                                       user_id: n+1,
                                       shop_id: (n%3)+1,
                                       is_vip: true,
                                       expired_at: Date.today+365,
                                       totally_stars: 10+n,
                                       monthly_stars: 2+n,
                                       weekly_stars: n%5,
                                       likes: n
                                   })
end
#create_twiiters
10.times do |n|
  Pandora::Models::Twitter.create({
                                      id: n+1,
                                      content: "这是一个测试的动态,字数非常多,一定要凑够1000000000000000000000000000000000000字",
                                      author_id: n+1,
                                      designer_id: (n%5)+1,
                                      image_count: 1,
                                      stars: (n%3)+1
                                  })
end
#create_twitter_images
10.times do |n|
  Pandora::Models::TwitterImage.create({
                                           id: n+1,
                                           twitter_id: n+1,
                                           image_id: n+21,
                                           likes: n%3,
                                           rank: 1
                                       })
end
#create_favorite_designers
10.times do |n|
  Pandora::Models::FavoriteDesigner.create({
                                               id: n+1,
                                               user_id: n+1,
                                               designer_id: (n%5)+1
                                           })
end
#create_favorite_images
10.times do |n|
  Pandora::Models::FavoriteImage.create({
                                            id: n+1,
                                            user_id: n+1,
                                            image_id: n+21
                                        })
end
#create_vitae
10.times do |n|
  Pandora::Models::Vita.create({
                                   id: n+1,
                                   designer_id: (n%5)+1,
                                   desc: "这是测试用的设计师自我介绍,要很多很多很多很多很多很多很多很多很多很多很多很多很多很多很多很多很多很多很多很多很多很多很多很多很多很多字",
                               })
end
#create_viat_images
10.times do |n|
  Pandora::Models::VitaImage.create({
                                        id: n+1,
                                        vita_id: n+1,
                                        image_id: n+41,
                                    })
end
#create_messages
10.times do |n|
  Pandora::Models::Message.create({
                                      id: n+1,
                                      user_id: n+1,
                                      content: "这是测试用的消息",
                                      is_new: true
                                  })
end