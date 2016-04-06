require 'controllers/commissioner_controller'
module API
  class CommissionerAPI
    def self.registered(app)
      app.post '/commissioner/register' do
        callback = params.delete('callback')
        result = CommissionerController.call(:register, [params['phone_number'], params['name'], params['password'], params['code']])
        return_response callback, result
      end

      app.get '/commissioner/login' do
        callback = params.delete('callback')
        result = CommissionerController.call(:login, [params['phone_number'], params['password']])
        return_response callback, result
      end

      app.get '/commissioner/details' do
        callback = params.delete('callback')
        result = CommissionerController.call(:details, [params['c_id'].to_i])
        return_response callback, result
      end

      app.post '/commissioner/delete_shop' do
        callback = params.delete('callback')
        result = CommissionerController.call(:delete_shop, [params['c_id'].to_i, params['shop_id'].to_i])
        return_response callback, result
      end

      app.get '/commissioner/promotion_logs' do
        callback = params.delete('callback')
        result = CommissionerController.call(:promotion_logs, [params['c_id'].to_i, params['page_size'].to_i, params['current_page'].to_i])
        return_response callback, result
      end

      app.get '/commissioner/users' do
        callback = params.delete('callback')
        result = CommissionerController.call(:promotion_users, [params['c_id'].to_i, params['page_size'].to_i, params['current_page'].to_i])
        return_response callback, result
      end

      app.get '/commissioner/designers' do
        callback = params.delete('callback')
        result = CommissionerController.call(:promotion_designers, [params['c_id'].to_i, params['page_size'].to_i, params['current_page'].to_i])
        return_response callback, result
      end

      app.get '/commissioner/vip_designers' do
        callback = params.delete('callback')
        result = CommissionerController.call(:promotion_vip_designers, [params['c_id'].to_i, params['page_size'].to_i, params['current_page'].to_i])
        return_response callback, result
      end

      app.get '/commissioner/shop_promotion_logs' do
        callback = params.delete('callback')
        result = CommissionerController.call(:shop_promotion_logs, [params['c_id'].to_i, params['shop_id'].to_i, params['page_size'].to_i, params['current_page'].to_i])
        return_response callback, result
      end

      app.get '/commissioner/shop_all_promotion_logs' do
        callback = params.delete('callback')
        result = CommissionerController.call(:shop_all_promotion_logs, [params['shop_id'].to_i, params['page_size'].to_i, params['current_page'].to_i])
        return_response callback, result
      end

      app.post '/commissioner/add_promotion_log' do
        callback = params.delete('callback')
        result = CommissionerController.call(:add_promotion_log, [params['c_id'].to_i, params['user_phone_number'], params['mobile_type']])
        return_response callback, result
      end

      app.post '/commissioner/del_promotion_log' do
        callback = params.delete('callback')
        result = CommissionerController.call(:del_promotion_log, [params['log_id'].to_i])
        return_response callback, result
      end


      app.post '/commissioner/add_shop_promotion_log' do
        callback = params.delete('callback')
        result = CommissionerController.call(:add_shop_promotion_log, [params['c_id'].to_i, params['shop_id'].to_i, params['content']])
        return_response callback, result
      end

      app.post '/commissioner/register_shop' do
        callback = params.delete('callback')
        image_paths = params['image_paths'].split(",")
        args = [params['name'], params['address'], params['longitude'], params['latitude'], params['scale'], params['category'], params['desc'], params['c_id'].to_i, image_paths, params['province'], params['city']]
        result = CommissionerController.call(:register_shop, args)
        return_response callback, result
      end

      app.get '/commissioner/search_pagination_shops' do
        callback = params.delete('callback')
        result = CommissionerController.call(:search_shops, [params['query'], params['page_size'].to_i, params['current_page'].to_i, params['order_by']])
        return_response callback, result
      end

      app.get '/commissioner/shops' do
        callback = params.delete('callback')
        result = CommissionerController.call(:shops, [params['page_size'].to_i, params['current_page'].to_i, params['order_by']])
        return_response callback, result
      end
    end
  end
end