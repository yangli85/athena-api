require 'pay/wechat_pay'

describe Pay::WechatPay do
  let(:fake_wx_app_id) { "1234" }
  let(:fake_wx_api_key) { "12345678" }
  let(:fake_wx_mch_id) { "1111" }
  let(:fake_pre_pay_id) { "wx124215211" }
  let(:fake_logger) { double "Common::Logging" }

  before do
    allow(subject).to receive(:logger).and_return(fake_logger)
    allow(fake_logger).to receive(:error)
    allow(ENV).to receive(:WX_APP_ID).and_return(fake_wx_app_id)
    allow(ENV).to receive(:WX_API_KEY).and_return(fake_wx_api_key)
    allow(ENV).to receive(:WX_MCH_ID).and_return(fake_wx_mch_id)
    allow(SecureRandom).to receive_message_chain(:uuid, :tr).and_return("4dff7af0ba53470a9489b91304540f6a")
    allow(Time).to receive_message_chain(:now, :to_i, :to_s).and_return("1459393503")
  end

  describe "#generate_app_pay_req" do
    it "should return correct req params" do
      expect(subject.generate_pay_req fake_pre_pay_id).to eq (
                                                                     {
                                                                         :appid => "wx308c9e4ba193b71a",
                                                                         :partnerid => "1323273601",
                                                                         :prepayid => "wx124215211",
                                                                         :package => "Sign=WXPay",
                                                                         :noncestr => "4dff7af0ba53470a9489b91304540f6a",
                                                                         :timestamp => "1459393503",
                                                                         :sign => "541CAEA4CAED9D997BAC671004AA2B21"
                                                                     }
                                                                 )
    end

    it "should raise standard erorr if requires parameter is not given" do
      expect { subject.generate_pay_req "" }.to raise_error StandardError, "Pay Warn: missing required option: prepayid"
    end
  end

  describe "#create_prepay_order" do
    let(:fake_params) {
      {
          body: "stars",
          total_fee: 100,
          notify_url: "http://localhost:8080/pay/wechat_notify",
          trade_type: "APP",
          spbill_create_ip: "101.12.12.3"

      }
    }
    let(:fake_success_response) {
      "<xml>
            <return_code><![CDATA[SUCCESS]]></return_code>
            <return_msg><![CDATA[OK]]></return_msg>
            <appid><![CDATA[wx308c9e4ba193b71a]]></appid>
            <mch_id><![CDATA[1323273601]]></mch_id>
            <nonce_str><![CDATA[zJvWC2XtiaAjKoZh]]></nonce_str>
            <sign><![CDATA[30370AF5D6B67A3EC181C79F7E96D354]]></sign>
            <result_code><![CDATA[SUCCESS]]></result_code>
            <prepayid><![CDATA[wx201603311127326c16a4b6e50406235130]]></prepayid>
            <trade_type><![CDATA[APP]]></trade_type>
      </xml>"
    }
    let(:fake_failed_response) {
      "<xml>
            <return_code><![CDATA[FAIL]]></return_code>
            <return_msg><![CDATA[ERROR]]></return_msg>
            <err_code_des><![CDATA[系统错误]]></err_code_des>
            <err_code><![CDATA[SYSTEMERROR]]></err_code>

      </xml>"
    }

    before do
      allow(RestClient::Request).to receive(:execute).and_return(fake_success_response)
    end
    it "should return prepay details" do
      expect(subject.create_prepay_order fake_params, "wx125151515").to eq (
                                                                               {
                                                                                   "return_code" => "SUCCESS",
                                                                                   "return_msg" => "OK",
                                                                                   "appid" => "wx308c9e4ba193b71a",
                                                                                   "mch_id" => "1323273601",
                                                                                   "nonce_str" => "zJvWC2XtiaAjKoZh",
                                                                                   "sign" => "30370AF5D6B67A3EC181C79F7E96D354",
                                                                                   "result_code" => "SUCCESS",
                                                                                   "prepayid" => "wx201603311127326c16a4b6e50406235130",
                                                                                   "trade_type" => "APP"
                                                                               }
                                                                           )
    end

    it "should return nil if create failed" do
      allow(RestClient::Request).to receive(:execute).and_return(fake_failed_response)
      expect(fake_logger).to receive(:error).with("create wechat pay order failed ,detail:SYSTEMERROR-系统错误")
      expect(subject.create_prepay_order fake_params, "wx125151515").to eq nil
    end

    it "should return nil if network error" do
      allow(RestClient::Request).to receive(:execute).and_raise StandardError
      expect(fake_logger).to receive(:error).with("create wechat pay order failed,detail:StandardError")
      expect{subject.create_prepay_order fake_params, "wx125151515"}.to_not raise_error
    end
  end
end