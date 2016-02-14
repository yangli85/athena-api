#encoding:utf-8
require 'controllers/user_controller'

describe UserController do
  let(:fake_phone) { '13812345678' }

  before do
    Pandora::Models::SMSCode.create(phone_number: fake_phone,code: '1234')
  end
  context 'failed' do
    it "should return error if code is not matched if latest sms code is nil" do
      Pandora::Models::SMSCode.destroy_all
      expect(subject.login fake_phone, '1234').to eq (
                                                                 {
                                                                     :result => "error",
                                                                     :message => "短信验证码错误!"
                                                                 }
                                                             )
    end

    it "should return error if code is not matched if code not match" do
      Pandora::Models::SMSCode.find_by_phone_number(fake_phone).update(code: '2345')
      expect(subject.login fake_phone, '1234').to eq (
                                                         {
                                                             :result => "error",
                                                             :message => "短信验证码错误!"
                                                         }
                                                     )
    end

    it "shoule return login error if have exception in login" do
      allow_any_instance_of(Pandora::Services::UserService).to receive(:create_user).and_raise StandardError
      expect(subject.login fake_phone, '1234').to eq (
                                                                 {
                                                                     :result => "error",
                                                                     :message => "对不起,登录失败,请您稍后再试!"
                                                                 }
                                                             )
    end
  end

  context 'new user' do
    it "should create a new user for given phone number" do
      subject.login fake_phone, '1234'
      expect(Pandora::Models::User.find_by_phone_number(fake_phone).name).to eq fake_phone
    end

    it "should return is_new user" do
      result = subject.login fake_phone, '1234'
      expect(result[:is_new]).to eq true
    end
  end

  context "not new user" do
    before do
      Pandora::Models::User.create(phone_number: fake_phone, name: fake_phone)
    end

    it "should return right login result" do
      expect(subject.login fake_phone, '1234').to eq (
                                                                 {
                                                                     :result => "success",
                                                                     :message => "登录成功",
                                                                     :is_new => false,
                                                                     :user_id => 1}
                                                             )
    end
  end
end