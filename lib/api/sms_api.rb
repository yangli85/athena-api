require 'controllers/sms_controller'
module API
  class SmsAPI
    def self.registered(app)
      app.get '/send_sms' do
        callback = params.delete('callback')
        result = SmsController.call(:send_sms_code, [params['phone_number']])
        return_response callback, result
      end
    end
  end
end



