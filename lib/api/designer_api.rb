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
      result = DesignerController.call(:get_designer_vitae, [params['designer_id'], params['page_size'], params['current_page']])
      return_response callback, result
    end

    app.get '/search_designers' do
      callback = params.delete('callback') # jsonp
      result = DesignerController.call(:search_designers, [params['page_size'], params['current_page'], params['query']])
      return_response callback, result
    end

    app.get '/designer_rank' do
      id = params['id']
      callback = params.delete('callback') # jsonp
      result = DesignerController.call(:get_designer_rank, [params['designer_id']]
      return_response callback, result
    end
  end
end



