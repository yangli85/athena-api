# encoding:UTF-8
require 'controllers/designer_controller'
module API
  class DesignerAPI
    def self.registered(app)

      app.get '/vicinal_designers' do
        callback = params.delete('callback') # jsonp
        args = [params['longitude'], params['latitude'], params['page_size'].to_i, params['current_page'].to_i, params['range'].to_i, params['order_by']]
        result = result = DesignerController.call(:get_vicinal_designers, args)
        return_response callback, result
      end

      app.get '/ordered_designers' do
        callback = params.delete('callback') # jsonp
        result = DesignerController.call(:get_ordered_designers, [params['page_size'].to_i, params['current_page'].to_i, params['order_by']])
        return_response callback, result
      end

      app.get '/designer_info' do
        callback = params.delete('callback') # jsonp
        result = DesignerController.call(:get_designer_info, [params['designer_id'].to_i])
        return_response callback, result
      end

      app.get '/designer_details' do
        callback = params.delete('callback') # jsonp
        result = DesignerController.call(:get_designer_details, [params['designer_id'].to_i])
        return_response callback, result
      end

      app.get '/designer_works' do
        callback = params.delete('callback')
        result = DesignerController.call(:get_designer_works, [params['designer_id'].to_i, params['page_size'].to_i, params['current_page'].to_i])
        return_response callback, result
      end

      app.get '/designer_vitae' do
        callback = params.delete('callback') # jsonp
        result = DesignerController.call(:get_designer_vitae, [params['designer_id'].to_i, params['page_size'].to_i, params['current_page'].to_i])
        return_response callback, result
      end

      app.get '/search_designers' do
        callback = params.delete('callback') # jsonp
        result = DesignerController.call(:search_designers, [params['page_size'].to_i, params['current_page'].to_i, params['query']])
        return_response callback, result
      end

      app.get '/search_customers' do
        callback = params.delete('callback') # jsonp
        result = DesignerController.call(:search_customers, [params['designer_id'].to_i, params['page_size'].to_i, params['current_page'].to_i, params['query']])
        return_response callback, result
      end

      app.get '/designer_rank' do
        callback = params.delete('callback') # jsonp
        result = DesignerController.call(:get_designer_rank, [params['designer_id'].to_i, params['order_by']])
        return_response callback, result
      end

      app.get '/designer_twitters' do
        callback = params.delete('callback')
        result = DesignerController.call(:get_designer_twitters, [params['designer_id'].to_i, params['page_size'].to_i, params['current_page'].to_i])
        return_response callback, result
      end

      app.post '/designer_delete_twitter' do
        callback = params.delete('callback')
        result = DesignerController.call(:delete_twitter, [params['designer_id'].to_i, params['twitter_id'].to_i])
        return_response callback, result
      end

      app.get '/designer_customers' do
        callback = params.delete('callback')
        result = DesignerController.call(:designer_customers, [params['designer_id'].to_i, params['page_size'].to_i, params['current_page'].to_i])
        return_response callback, result
      end

      app.post '/update_new_shop' do
        callback = params.delete('callback')
        args = [params['name'], params['address'], params['latitude'], params['longitude'], params['designer_id'].to_i, params['province'], params['city']]
        result = DesignerController.call(:update_new_shop, args)
        return_response callback, result
      end

      app.post '/update_shop' do
        callback = params.delete('callback')
        result = DesignerController.call(:update_shop, [params['designer_id'].to_i, params['shop_id'].to_i])
        return_response callback, result
      end

      app.get '/search_shops' do
        callback = params.delete('callback')
        result = DesignerController.call(:search_shops, [params['name']])
        return_response callback, result
      end

      app.post '/add_vita' do
        image_paths = params['image_paths'].split(",")
        callback = params.delete('callback')
        args = [params['desc'], image_paths, params['designer_id'].to_i]
        result = DesignerController.call(:create_vita, args)
        return_response callback, result
      end

      app.post '/del_vitae' do
        vita_ids = params['vita_ids'].split(',').map(&:to_i)
        callback = params.delete('callback')
        result = DesignerController.call(:delete_vitae, [vita_ids])
        return_response callback, result
      end

      app.post '/pay_for_vip' do
        callback = params.delete('callback')
        result = DesignerController.call(:pay_for_vip, [params['designer_id']])
        return_response callback, result
      end

      app.get '/shop_details' do
        callback = params.delete('callback')
        result = DesignerController.call(:shop_details, [params['id']])
        return_response callback, result
      end

      app.get '/get_commend_designers' do
        callback = params.delete('callback')
        result = DesignerController.call(:get_commend_designers, [])
        return_response callback, result
      end
    end
  end
end



