require 'controllers/user_controller'

class AuthenticateAPI
  def self.registered(app)
    app.get '/login' do
      callback = params.delete('callback') # jsonp
      phone_numer = params['phone_number']
      code = params['code']
      result = UserController.new.login phone_numer, code
      return_response callback, result
    end
  end
end