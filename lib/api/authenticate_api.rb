require 'controllers/user_controller'

class AuthenticateAPI
  def self.registered(app)
    app.get '/login' do
      callback = params.delete('callback') # jsonp
      result = UserController.call(:login, [params['phone_number'], params['code']])
      return_response callback, result
    end
  end
end