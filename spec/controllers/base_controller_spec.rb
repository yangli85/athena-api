#encoding:utf-8
require 'controllers/base_controller'

describe BaseController do
  let(:fake_method) { :send_sms }
  let(:fake_params) { ['phone_number', 'code'] }

  context "args error" do
    it "should return args error if any args is nil" do
      expect(BaseController.call fake_method, [nil, 'arg']).to eq (
                                                                      {
                                                                          :status => "ERROR",
                                                                          :message => "参数传递错误."
                                                                      }
                                                                  )
    end

    it "should return args error if any args is empty" do
      expect(BaseController.call fake_method, [nil, '        ']).to eq (
                                                                           {
                                                                               :status => "ERROR",
                                                                               :message => "参数传递错误."
                                                                           }
                                                                       )
    end
  end

  context "common error" do
    it "should return common error message" do
      allow_any_instance_of(BaseController).to receive(:send).and_raise Common::Error, "短信发送失败."
      expect(BaseController.call fake_method, fake_params).to eq (
                                                                     {
                                                                         :status => "ERROR",
                                                                         :message => "短信发送失败."
                                                                     }
                                                                 )
    end
  end

  context "other errors" do
    it "should return system error message" do
      allow_any_instance_of(BaseController).to receive(:send).and_raise StandardError
      expect(BaseController.call fake_method, fake_params).to eq (
                                                                     {
                                                                         :status => "ERROR",
                                                                         :message => "对不起,系统错误,请稍后再试."
                                                                     }
                                                                 )
    end
  end
end