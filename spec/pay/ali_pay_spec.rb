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
    allow(OpenSSL::PKey::RSA).to receive(:new).and_return(fake_rsa)
    allow(fake_rsa).to receive(:sign)
    allow(Base64).to receive(:strict_encode64).and_return(fake_rsa_sign)
    allow(subject).to receive(:logger).and_return(fake_logger)
    allow(fake_logger).to receive(:error)
    allow(ENV).to receive(:ALI_RSA_PUBLIC_KEY).and_return(fake_public_key)
    allow(ENV).to receive(:ALI_RSA_PRIVATE_KEY).and_return(fake_private_key)
    allow(ENV).to receive(:ALI_MCH_ID).and_return(fake_mch_id)
    allow(SecureRandom).to receive_message_chain(:uuid, :tr).and_return("4dff7af0ba53470a9489b91304540f6a")
    allow(Time).to receive_message_chain(:now, :to_i, :to_s).and_return("1459393503")
  end

  describe "#generate_pay_req" do
    it "should return correct req params" do
      expect(subject.generate_pay_req fake_params, fake_out_trade_no).to eq (
                                                                                {
                                                                                    :subject => "stars",
                                                                                    :total_fee => 100,
                                                                                    :notify_url => "http://localhost:8080/pay/ali_notify",
                                                                                    :body => "stars",
                                                                                    :service => "mobile.securitypay.pay",
                                                                                    :partner => "2088221419118326",
                                                                                    :_input_charset => "utf-8",
                                                                                    :out_trade_no => "ali1245215",
                                                                                    :payment_type => "1",
                                                                                    :seller_id => "2088221419118326",
                                                                                    :sign_type => "RSA",
                                                                                    :sign => "MIICeAIBADANBgkqhkiG9w0B"
                                                                                }
                                                                            )
    end

    it "should raise standard erorr if requires parameter is not given" do
      expect { subject.generate_pay_req fake_params, nil }.to raise_error StandardError, "Pay Warn: missing required option: out_trade_no"
    end
  end

end