# encoding: UTF-8
class UserMessageAPI
  def self.registered(app)
    app.get '/messages' do
      user_id =params['user_id']
      callback = params.delete('callback') # jsonp
      {
          id: 12,
          details: 'tracy 关注了你',
          created_at: '2014-12-12 12:12:12'
      }
      return_response callback, result
    end

    app.post '/del_messages' do
      message_id = params['message_id']
      callback = params.delete('callback') # jsonp
      result = {
          result: 'success'
      }
      return_response callback, result
    end
  end
end


