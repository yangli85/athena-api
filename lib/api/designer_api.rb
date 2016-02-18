# encoding:UTF-8
require 'controllers/designer_controller'
class DesignerAPI
  def self.registered(app)

    app.get '/vicinal_designers' do
      callback = params.delete('callback') # jsonp
      result = result = DesignerController.call(:get_vicinal_designers, [params['longtitude'], params['latitude'], params['page_size'], params['current_page'], params['order_by']])
      return_response callback, result
    end

    app.get '/ordered_designers' do
      callback = params.delete('callback') # jsonp
      result = DesignerController.call(:get_ordered_designers, [params['page_size'], params['current_page'], params['order_by']])
      return_response callback, result
    end

    app.get 'designer_info' do
      callback = params.delete('callback') # jsonp
      result = DesignerController.call(:get_designer_info, [params['designer_id']])
      return_response callback, result
    end

    app.get 'designer_works' do
      callback = params.delete('callback')
      result = DesignerController.call(:get_designer_works, [params['designer_id'], params['page_size'], params['current_page']])
      return_response callback, result
    end

    app.get '/designer_vitae' do
      callback = params.delete('callback') # jsonp
      result = result = DesignerController.call(:get_designer_vitae, [params['designer_id'], params['page_size'], params['current_page']])
      return_response callback, result
    end

    app.get '/search_designer' do
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

    app.get '/my_rank' do
      id = params['id']
      callback = params.delete('callback') # jsonp
      result = {
          rank: 100
      }
      return_response callback, result
    end
  end
end



