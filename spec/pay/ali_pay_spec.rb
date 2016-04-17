require 'pay/ali_pay'

describe Pay::AliPay do
  let(:fake_public_key) { "MIGfMA0GCSqGSI" }
  let(:fake_private_key) { "MIICeAIBADANBgkqhkiG9w0B" }
  let(:fake_mch_id) { "1111" }
  let(:fake_out_trade_no) { "ali1245215" }
  let(:fake_logger) { double("Common::Logging") }
  let(:fake_rsa_sign) { "MIICeAIBADANBgkqhkiG9w0B" }
  let(:fake_rsa) { double("OpenSSL::PKey::RSA") }
  let(:fake_params) {
    {
        subject: "stars",
        total_fee: 100,
        notify_url: "http://localhost:8080/pay/ali_notify",
        body: "stars"
    }
  }

  before do
    allow(ENV).to receive(:[]).with("ALI_MCH_ID").and_return(fake_mch_id)
    allow(subject).to receive(:logger).and_return(fake_logger)
    allow(fake_logger).to receive(:error)
    allow(SecureRandom).to receive_message_chain(:uuid, :tr).and_return("4dff7af0ba53470a9489b91304540f6a")
    allow(Time).to receive_message_chain(:now, :to_i, :to_s).and_return("1459393503")
  end

  describe "#generate_pay_req" do
    it "should return correct req params" do
      expect(subject.generate_pay_req fake_params, fake_out_trade_no).to eq (
                                                                                "subject=\"stars\"&total_fee=\"100\"&notify_url=\"http://localhost:8080/pay/ali_notify\"&body=\"stars\"&service=\"mobile.securitypay.pay\"&partner=\"1111\"&_input_charset=\"utf-8\"&out_trade_no=\"ali1245215\"&payment_type=\"1\"&seller_id=\"1111\"&sign=\"TCWXAVj9yd5CcSn5E7q5GRrLB2KxPGlskFlM451BoEI6SfkEMx1iybUI53oWljkl7tv3FldfJNeKVuLk8B2X6egMU%2FEges%2Fqq1pnaVMoD%2B9GjY0Ep7jO7pEZfYJsQWTYqo9xUYiLZLUUcQgQwGlOZKmSTguYzX%2BCMavFk86di0E%3D\"&sign_type=\"RSA\""
                                                                            )
    end
    it "should raise standard erorr if requires parameter is not given" do
      expect { subject.generate_pay_req fake_params, nil }.to raise_error StandardError, "Pay Warn: missing required option: out_trade_no"
    end

  end

end