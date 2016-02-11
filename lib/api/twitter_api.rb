# encoding: UTF-8
class TwitterAPI
  def self.registered(app)
    app.get '/twitter_images' do
      order_by = params['order_by']
      page_size = params['page_size']
      current_page = params['current_page']
      callback = params.delete('callback') # jsonp
      result = [
          {
              s_image: 'images/twitter/1.png',
              likes: 12,
              designer_avatar: 'images/avatar/1.jpg',
              designer_id: 12,
              twitter_id: 1,
              order: 2
          },
          {
              s_image: 'images/twitter/2.png',
              likes: 11,
              designer_avatar: 'images/avatar/2.jpg',
              designer_id: 13,
              twitter_id: 2,
              order: 4
          },
          {
              s_image: 'images/twitter/3.png',
              likes: 12,
              designer_avatar: 'images/avatar/3.jpg',
              designer_id: 12,
              twitter_id: 3,
              order: 2
          },
          {
              s_image: 'images/twitter/4.png',
              likes: 11,
              designer_avatar: 'images/avatar/4.jpg',
              designer_id: 13,
              twitter_id: 4,
              order: 4
          },
          {
              s_image: 'images/twitter/8.png',
              likes: 12,
              designer_avatar: 'images/avatar/5.jpg',
              designer_id: 12,
              twitter_id: 5,
              order: 2
          },
          {
              s_image: 'images/twitter/5.png',
              likes: 11,
              designer_avatar: 'images/avatar/6.jpg',
              designer_id: 13,
              twitter_id: 6,
              order: 4
          },
          {
              s_image: 'images/twitter/6.png',
              likes: 12,
              designer_avatar: 'images/avatar/7.jpg',
              designer_id: 12,
              twitter_id: 7,
              order: 2
          },
          {
              s_image: 'images/twitter/7.png',
              likes: 11,
              designer_avatar: 'images/avatar/8.jpg',
              designer_id: 13,
              twitter_id: 8,
              order: 4
          },
      ]
      return_response callback, result
    end

    app.get '/twitter_images_view' do
      id = params['id']
      user_id = params['user_id']
      callback = params.delete('callback') # jsonp
      result = {
          images:
              [
                  {
                      image: 'images/twitter/11.png',
                      likes: 13,
                      added: false
                  },
                  {
                      image: 'images/twitter/12.png',
                      likes: 13,
                      added: false
                  },
                  {
                      image: 'images/twitter/13.png',
                      likes: 25,
                      added: true
                  },
                  {
                      image: 'images/twitter/14.png',
                      likes: 1,
                      added: true
                  }
              ],
          id: 1,
          designer_avatar: 'images/avatar/2.jpg',
          designer_id: 2
      }
      return_response callback, result
    end

    app.get 'twitters' do
      order_by = params['order_by']
      pages_size = params['page_size']
      current_page = params['current_page']
      user_id = params['user_id']
      longtitude = params['longtitude']
      latitude = params['latitude']
      callback = params.delete('callback') # jsonp
      result = [
          {
              id: 12,
              consumer_name: 'Casey',
              consumer_avatar: 'imgaes/avatar/2.png',
              content: '感谢Tommy老师给我设计的新发型,感觉自己年轻了,有木有!',
              likes: 21,
              designer_id: 12,
              designer_avatar: 'images/avatar/4.png',
              created_at: '2015-12-12 12:12:12',
              images:
                  [
                      {
                          s_image: 'images/twitter/11.jpg',
                          image: 'images/twitter/11.jpg',
                          likes: 12,
                          added: false,
                          order: 1
                      },
                      {
                          s_image: 'images/twitter/12.jpg',
                          image: 'images/twitter/12.jpg',
                          likes: 22,
                          added: false,
                          order: 2
                      }
                  ]
          },
          {
              id: 13,
              consumer_name: 'Casey',
              consumer_avatar: 'imgaes/avatar/3.png',
              content: '感谢Tommy老师给我设计的新发型,感觉自己年轻了,有木有!',
              likes: 21,
              designer_id: 12,
              designer_avatar: 'images/avatar/5.png',
              created_at: '2015-12-12 12:12:12',
              images:
                  [
                      {
                          s_image: 'images/twitter/13.jpg',
                          image: 'images/twitter/13.jpg',
                          likes: 12,
                          added: false,
                          order: 1
                      },
                      {
                          s_image: 'images/twitter/14.jpg',
                          image: 'images/twitter/14.jpg',
                          likes: 2,
                          added: false,
                          order: 2
                      }
                  ]
          },
          {
              id: 13,
              consumer_name: 'Casey',
              consumer_avatar: 'imgaes/avatar/3.png',
              content: '感谢Tommy老师给我设计的新发型,感觉自己年轻了,有木有!',
              likes: 21,
              designer_id: 12,
              designer_avatar: 'images/avatar/5.png',
              created_at: '2015-12-12 12:12:12',
              images:
                  [
                      {
                          s_image: 'images/twitter/13.jpg',
                          image: 'images/twitter/13.jpg',
                          likes: 12,
                          added: false,
                          order: 1
                      },
                      {
                          s_image: 'images/twitter/14.jpg',
                          image: 'images/twitter/14.jpg',
                          likes: 2,
                          added: false,
                          order: 2
                      }
                  ]
          },
          {
              id: 13,
              consumer_name: 'Casey',
              consumer_avatar: 'imgaes/avatar/3.png',
              content: '感谢Tommy老师给我设计的新发型,感觉自己年轻了,有木有!',
              likes: 21,
              designer_id: 12,
              designer_avatar: 'images/avatar/5.png',
              created_at: '2015-12-12 12:12:12',
              images:
                  [
                      {
                          s_image: 'images/twitter/13.jpg',
                          image: 'images/twitter/13.jpg',
                          likes: 12,
                          added: false,
                          order: 1
                      },
                      {
                          s_image: 'images/twitter/14.jpg',
                          image: 'images/twitter/14.jpg',
                          likes: 2,
                          added: false,
                          order: 2
                      }
                  ]
          },
          {
              id: 13,
              consumer_name: 'Casey',
              consumer_avatar: 'imgaes/avatar/3.png',
              content: '感谢Tommy老师给我设计的新发型,感觉自己年轻了,有木有!',
              likes: 21,
              designer_id: 12,
              designer_avatar: 'images/avatar/5.png',
              created_at: '2015-12-12 12:12:12',
              images:
                  [
                      {
                          s_image: 'images/twitter/13.jpg',
                          image: 'images/twitter/13.jpg',
                          likes: 12,
                          added: false,
                          order: 1
                      },
                      {
                          s_image: 'images/twitter/14.jpg',
                          image: 'images/twitter/14.jpg',
                          likes: 2,
                          added: false,
                          order: 2
                      }
                  ]
          }
      ]
      return_response callback, result
    end

    app.get '/search_twitters' do
      order_by = params['order_by']
      pages_size = params['page_size']
      current_page = params['current_page']
      user_id = params['user_id']
      query = params['query']
      callback = params.delete('callback')
      result = [
          {
              id: 12,
              consumer_name: 'Casey',
              consumer_avatar: 'imgaes/avatar/2.png',
              content: '感谢Tommy老师给我设计的新发型,感觉自己年轻了,有木有!',
              likes: 21,
              designer_id: 12,
              designer_avatar: 'images/avatar/4.png',
              created_at: '2015-12-12 12:12:12',
              images:
                  [
                      {
                          s_image: 'images/twitter/11.jpg',
                          image: 'images/twitter/11.jpg',
                          likes: 12,
                          added: false,
                          order: 1
                      },
                      {
                          s_image: 'images/twitter/12.jpg',
                          image: 'images/twitter/12.jpg',
                          likes: 22,
                          added: false,
                          order: 2
                      }
                  ]
          }
      ]
      return_response callback, result
    end

    app.post '/add_twitter' do
      authoer_id = params['author_id']
      designer_id = params['designer_id']
      context = params['context']
      stars = params['stars']
      latitude = params['latitude']
      longtitude = params['longtitude']
      images = params['images']
      twitter_id = 1
      images.each do |image|
        File.open("images/1.jpg", "rb") do |file|
          file.write(image.read)
        end
      end
      callback = params.delete('callback') # jsonp
      result = {
          result: 'success'
      }
      return_response callback, result
    end
  end
end



