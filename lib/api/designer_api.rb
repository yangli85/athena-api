# encoding:UTF-8
require 'api/base_api'

class DesignerAPI < BaseAPI

  get '/vicinal_designers' do
    latitude = params['latitude']
    longtitude = params['longtitude']
    page_size = params['page_size']
    current_page = params['current_page']
    range = params['range']
    order_by = params['range']
    callback = params.delete('callback') # jsonp
    result = [
        {
            id: 1,
            avatar: 'images/avatar/2.jpg',
            designer_name: 'Tommy',
            shop_name: '希客造型(绿地世纪城店)',
            distance: 0.5,
            stars: 50,
            latitude: '34.27422',
            longtitude: '108.94311'
        },
        {
            id: 2,
            avatar: 'images/avatar/1.jpg',
            designer_name: 'Tommy',
            shop_name: '希客造型(绿地世纪城店)',
            distance: 0.6,
            stars: 50,
            latitude: '34.27422',
            longtitude: '108.94311'
        }
    ]
    return_response callback, result
  end

  get '/ordered_designers' do
    page_size = params['page_size']
    current_page = params['current_page']
    order_by = params['total_stars']
    callback = params.delete('callback') # jsonp
    result = [
        {
            id: 1,
            avatar: 'images/avatar/2.jpg',
            designer_name: 'Tommy',
            shop_name: '希客造型(绿地世纪城店)',
            distance: 0.5,
            stars: 100,
            latitude: '34.27422',
            longtitude: '108.94311'
        },
        {
            id: 2,
            avatar: 'images/avatar/1.jpg',
            designer_name: 'Tommy',
            shop_name: '希客造型(绿地世纪城店)',
            distance: 0.4,
            stars: 98,
            latitude: '34.27422',
            longtitude: '108.94311'
        }
    ]
    return_response callback, result
  end

  get 'designer_info' do
    designer_id = params['designer_id']
    callback = params.delete('callback') # jsonp
    result = {
        id: designer_id,
        avatar: 'images/avatar/3.jpg',
        name: 'Tommy',
        shop_name: '希客造型(绿地世纪城)',
        latitude: '34.27422',
        longtitude: '108.94311',
        sex: 'male',
        stars: 120,
        rank: 12
    }
    return_response callback, result
  end

  get 'designer_works' do
    designer_id = params['designer_id']
    callback = params.delete('callback')
    result = {
        images:
            [
                {
                    twitter_id: 12,
                    s_image: 'images/twitter/1.png',
                    image: 'images/twitter/1.png',
                    likes: 12,
                    added: false
                },
                {
                    twitter_id: 13,
                    s_image: 'images/twitter/2.png',
                    image: 'images/twitter/2.png',
                    likes: 12,
                    added: false
                },
                {
                    twitter_id: 12,
                    s_image: 'images/twitter/3.png',
                    image: 'images/twitter/3.png',
                    likes: 12,
                    added: false
                },
                {
                    twitter_id: 13,
                    s_image: 'images/twitter/4.png',
                    image: 'images/twitter/4.png',
                    likes: 12,
                    added: false
                },
                {
                    twitter_id: 12,
                    s_image: 'images/twitter/5.png',
                    image: 'images/twitter/5.png',
                    likes: 12,
                    added: false
                },
                {
                    twitter_id: 13,
                    s_image: 'images/twitter/6.png',
                    image: 'images/twitter/6.png',
                    likes: 12,
                    added: false
                }
            ],
        designer_id: 1,
        designer_avatar: 'images/avatar/7.jpg'
    }
    return_response callback, result
  end

  get '/designer_vitae' do
    designer_id = params['designer_id']
    callback = params.delete('callback') # jsonp
    result = [
        {
            id: designer_id,
            vita_id: 1,
            desc: '这是我们新进的烫发设备,很高端吧!',
            s_image: 'images/vitae/1.jpg',
            image: 'images/vitae/1.jpg',
            created_at: '2014-12-12 12:12:12'
        },
        {
            id: designer_id,
            vita_id: 2,
            desc: '这是我们新进的烫发设备,很高端吧!',
            s_image: 'images/vitae/2.jpg',
            image: 'images/vitae/2.jpg',
            created_at: '2014-12-12 12:12:12'
        }
    ]
    return_response callback, result
  end

  get '/search_designer' do
    page_size = params['page_size']
    current_page = params['current_page']
    order_by = params['order_by']
    query =params['query']
    callback = params.delete('callback') # jsonp
    result = [
        {
            id: 10,
            avatar: 'images/avatar/2.jpg',
            designer_name: 'Tommy',
            shop_name: '希客造型(绿地世纪城店)',
            distance: 0.5,
            stars: 50,
            latitude: '34.27422',
            longtitude: '108.94311'
        },
        {
            id: 17,
            avatar: 'images/avatar/5.jpg',
            designer_name: 'Tommy',
            shop_name: '希客造型(绿地世纪城店)',
            distance: 0.5,
            stars: 50,
            latitude: '34.27422',
            longtitude: '108.94311'
        }
    ]
    return_response callback, result
  end

  get '/my_rank' do
    id = params['id']
    callback = params.delete('callback') # jsonp
    result = {
        rank: 100
    }
    return_response callback, result
  end
end



