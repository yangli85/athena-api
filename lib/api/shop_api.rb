#encoding:utf-8
class ShopAPI
  def self.registered(app)
    app.get '/shop_info' do
      shop_id = params['shop_id']
      callback = params.delete('callback') # jsonp
      result ={
          shop_id: 1,
          name: '希克造型(绿地世纪城店)',
          address: '丈八二路绿地笔克',
          longtitude: '108.1242',
          latitude: '340.124'
      }
      return_response callback, result
    end

    app.post 'change_shop' do
      shop_name = params['shop_name']
      address = params['address']
      latitude = params['latitude']
      longtitude = params['longtitude']
      designer_id = params['designer_id']
      callback = params.delete('callback') # jsonp
      result = {
          result: 'success'
      }
      return_response callback, result
    end

    app.post 'update_shop' do
      shop_id = params['shop_id']
      designer_id = params['designer_id']
      callback = params.delete('callback') # jsonp
      result = {
          result: 'success'
      }
      return_response callback, result
    end

    app.get 'search_shop' do
      name = params['name']
      callback = params.delete('callback') # jsonp
      result =[
          {
              shop_id: 1,
              name: '希克造型1',
              address: '丈八六路',
              latitude: 121.124,
              lontitude: 108.244,
          },
          {
              shop_id: 2,
              name: '希克造型',
              address: '丈八六路',
              latitude: 121.124,
              lontitude: 108.244,
          }
      ]
      return_response callback, result
    end
  end
end



