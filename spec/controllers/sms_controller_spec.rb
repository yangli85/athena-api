#encoding:utf-8
require 'controllers/sms_controller'

describe SmsController do
  let(:fake_phone_number) { "13812345678" }

  describe 'send_sms_code' do
    before do
      allow_any_instance_of(SmsController).to receive(:rand).and_return('9999')
      allow_any_instance_of(Sms::AthenaSms).to receive(:send_msg).and_return(true)
    end

    it "should send sms and return correct result" do
      expect(SmsController.new.send_login_sms_code fake_phone_number).to eq (
                                                                                {
                                                                                    :status => "SUCCESS",
                                                                                    :message => "短信发送成功"
                                                                                }
                                                                            )
    end

    it "should update code to db" do
      SmsController.new.send_login_sms_code fake_phone_number
      sms_code = Pandora::Models::SMSCode.find_by_phone_number(fake_phone_number)
      expect(sms_code.code).to eq '9999'
    end

    it "should return error result if send sms failed" do
      allow_any_instance_of(Sms::AthenaSms).to receive(:send_msg).and_raise StandardError
      expect { SmsController.new.send_login_sms_code fake_phone_number }.to raise_error StandardError
    end
  end
end