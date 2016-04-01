require "controllers/wechat_pay_controller"

describe WechatPayController do
  describe "#notify" do
    let(:fake_wechat_pay) { double("Pay::WechatPay") }
    let(:out_trade_no) { "wx12141515" }
    let(:transaction_id) { '1217752501201407033233368018' }
    let(:user) { create(:user) }
    let(:designer) { create(:designer, user: user) }
    let(:account) { create(:account, user: user) }
    let(:order) { create(:order, {product: "STAR", count: 1, user_id: user.id}) }
    let(:payment_log) { create(:payment_log, {order: order, out_trade_no: out_trade_no}) }

    before do
      allow(Pay::WechatPay).to receive(:new).and_return(fake_wechat_pay)
      order
      designer
      payment_log
      account
    end

    context "verify success" do
      before do
        allow(fake_wechat_pay).to receive(:verify?).and_return(true)
      end

      context "first notify" do
        it "should update STAR order status to be success" do
          params = {
              "out_trade_no" => out_trade_no,
              "result_code" => "SUCCESS",
              "transaction_id" => transaction_id
          }
          subject.notify params
          new_payment_log = Pandora::Models::PaymentLog.find(payment_log.id)
          new_order = Pandora::Models::Order.find(order.id)
          expect(new_payment_log.trade_status).to eq "SUCCESS"
          expect(new_payment_log.trade_no).to eq transaction_id
          expect(new_order.result).to eq "1颗星星购买成功"
          expect(new_order.status).to eq "SUCCESS"
        end

        it "should update VIP order status to be success" do
          order.update!(product: "VIP")
          params = {
              "out_trade_no" => out_trade_no,
              "result_code" => "SUCCESS",
              "transaction_id" => transaction_id
          }
          subject.notify params
          new_payment_log = Pandora::Models::PaymentLog.find(payment_log.id)
          new_order = Pandora::Models::Order.find(order.id)
          expect(new_payment_log.trade_status).to eq "SUCCESS"
          expect(new_payment_log.trade_no).to eq transaction_id
          expect(new_order.result).to eq "会员续费成功"
          expect(new_order.status).to eq "SUCCESS"
        end

        it "should update order status UNPAY if return_code is not SUCCESS" do
          params = {
              "out_trade_no" => out_trade_no,
              "result_code" => "FAIL",
              "transaction_id" => transaction_id
          }
          subject.notify params
          new_payment_log = Pandora::Models::PaymentLog.find(payment_log.id)
          new_order = Pandora::Models::Order.find(order.id)
          expect(new_payment_log.trade_status).to eq "FAIL"
          expect(new_payment_log.trade_no).to eq transaction_id
          expect(new_order.result).to eq "买家支付失败"
          expect(new_order.status).to eq "UNPAY"
        end
      end

      context "not first notify" do
        it "should not do anything and directly return success" do
          params = {
              "out_trade_no" => out_trade_no,
              "result_code" => "SUCCESS",
              "transaction_id" => transaction_id
          }
          order.update(:status=>"FAIL")
          expect( subject.notify params).to eq ({:return_code=>"SUCCESS", :return_msg=>"OK"})
          expect_any_instance_of(Pandora::Services::UserService).not_to receive(:update_order)
          expect_any_instance_of(Pandora::Services::UserService).not_to receive(:update_payment_log)
        end
      end
    end

    context "verify fail" do
      before do
        allow(fake_wechat_pay).to receive(:verify?).and_return(false)
      end

      it "should directly return sign fail" do
        expect(subject.notify({})).to eq ({return_code: "FAIL", return_msg: "签名失效"})
      end
    end
  end
end