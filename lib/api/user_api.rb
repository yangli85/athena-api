require 'api/base_api'

class UserAPI < BaseAPI
  get '/consumer_info' do
    user_id = params['user_id']
    callback = params.delete('callback') # jsonp
    result ={
        id: user_id,
        avatar: 'images/avatar/1.png',
        name: 'Tracy',
        score: 290,
        sex: 'male',
        new_message: 4,
        stars: 5,
        twitters: 34,
        phone_number: 18512334124
    }
    return_response callback, result
  end

  get '/designer_info' do
    user_id = params['user_id']
    callback = params.delete('callback') # jsonp
    result = {
        id: user_id,
        avatar: 'images/avatar/1.png',
        name: 'Tracy',
        score: 290,
        sex: 'male',
        new_message: 4,
        stars: 5,
        twitters: 34,
        phone_number: 18512334124,
        shop_id: 12,
        shop_name: '希克造型(绿地世纪城店)',
        about_me: '这是我的工作室'
    }
    return_response callback, result
  end

  get '/designer_shop' do
    user_id = params['user_id']
    callback = params.delete('callback') # jsonp
    result = {
        id: user_id,
        shop_id: 1,
        name: '希克造型',
        address: '丈八六路',
        latitude: 103.124,
        longtitude: 108.212,
    }
    return_response callback, result
  end

  post '/add_image_to_favorites' do
    user_id = params['user_id']
    image_id = params['id']
    callback = params.delete('callback') # jsonp
    result = {
        result: 'success'
    }
    return_response callback, result
  end

  post '/del_image_from_favorites' do
    user_id = params['user_id']
    image_id = params['id']
    callback = params.delete('callback') # jsonp
    result = {
        result: 'success'
    }
    return_response callback, result
  end

  get 'favorite_images' do
    use_id = params['user_id']
    image_id = params['image_id']
    callback = params.delete('callback') # jsonp
    result =[
        {
            twitter_id: 12,
            images_id: 2,
            s_image: 'images/twitter/1.png',
            image: 'images/twitter/1.png',
            designer_id: 1,
            designer_avatar: 'images/avatar/1.jpg'
        },
        {
            twitter_id: 12,
            images_id: 4,
            s_image: 'images/twitter/2.png',
            image: 'images/twitter/2.png',
            designer_id: 1,
            designer_avatar: 'images/avatar/2.jpg'
        }
    ]
    return_response callback, result
  end

  post 'add_designer_to_favorites' do
    user_id = params['user_id']
    designer_id = params['designer_id']
    callback = params.delete('callback') # jsonp
    result = {
        result: 'success'
    }
    return_response callback, result
  end

  post 'del_designer_to_favorites' do
    user_id = params['user_id']
    designer_id = params['designer_id']
    callback = params.delete('callback') # jsonp
    result = {
        result: 'success'
    }
    return_response callback, result
  end

  get 'favorite_designers' do
    user_id = params['user_id']
    callback = params.delete('callback') # jsonp
    result =[
        {
            id: 10,
            avatar: 'images/avatar/1.jpg',
            designer_name: 'Tommy',
            shop_name: '希客造型(绿地世纪城店)',
            distance: 0.5,
            stars: 50,
            latitude: '34.27422',
            longtitude: '108.94311'
        },
        {
            id: 17,
            avatar: 'images/avatar/2.jpg',
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

  post 'delete_twitters' do
    user_id = params['user_id']
    twitter_id = params['twitter_id']
    callback = params.delete('callback') # jsonp
    result = {
        result: 'success'
    }
    return_response callback, result
  end

  get '/my_twitter' do
    user_id = params['user_id']
    pages_size = params['page_size']
    current_page = params['current_page']
    callback = params.delete('callback')
    result = result = [
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

  get 'designer_twitters' do
    designer_id = params['designer_id']
    pages_size = params['page_size']
    current_page = params['current_page']
    callback = params.delete('callback')
    result = result = [
        {
            id: 12,
            consumer_name: 'Casey',
            consumer_avatar: 'imgaes/avatar/2.png',
            content: '感谢Tommy老师给我设计的新发型,感觉自己年轻了,有木有!',
            likes: 21,
            designer_id: designer_id,
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
            designer_id: designer_id,
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
            designer_id: designer_id,
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
            designer_id: designer_id,
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
            designer_id: designer_id,
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

  get 'my_customers' do
    designer_id = params['designer_id']
    page_size = params['page_size']
    current_page = params['current_page']
    order_by = params['order_by']
    callback = params.delete('callback')
    result = [
        {
            user_id: 1,
            name: 'Jack',
            phone: '18611921242',
            avatar: 'images/avatar/1.jpg'
        },
        {
            user_id: 1,
            name: 'Jack',
            phone: '18611921242',
            avatar: 'images/avatar/2.jpg'
        }
    ]
    return_response callback, result
  end

  post 'del_vitae' do
    designer_id = params['designer_id']
    vita_ids = prams['vita_ids']
    callback = params.delete('callback') # jsonp
    result = {
        result: 'success'
    }
    return_response callback, result
  end

  post 'add_vitae' do
    designer_id = params['designer_id']
    vitae = params[vitae]
    result = {
        result: 'success'
    }
    return_response callback, result
  end

end



