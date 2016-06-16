require "controllers/ali_pay_controller"

describe AliPayController do
  describe "#notify" do
    let(:fake_ali_pay) { double("Pay::AliPay") }
    let(:out_trade_no) { "ali12141515" }
    let(:trade_no) { '1217752501201407033233368018' }
    let(:user) { create(:user, vitality: 0) }
    let(:designer) { create(:designer, user: user) }
    let(:account) { create(:account, {user: user, balance: 0}) }
    let(:order) { create(:order, {product: "STAR", count: 1, user_id: user.id, total_fee: 1}) }
    let(:payment_log) { create(:payment_log, {order: order, out_trade_no: out_trade_no}) }

    before do
      allow(Pay::AliPay).to receive(:new).and_return(fake_ali_pay)
      order
      designer
      payment_log
      account
    end

    context "verify success" do
      before do
        allow(fake_ali_pay).to receive(:verify?).and_return(true)
      end

      context "first notify" do
        it "should update STAR order status to be success" do
          params = {
              "out_trade_no" => out_trade_no,
              "trade_status" => "TRADE_FINISHED",
              "trade_no" => trade_no
          }
          subject.notify params
          new_payment_log = Pandora::Models::PaymentLog.find(payment_log.id)
          new_order = Pandora::Models::Order.find(order.id)
          expect(new_payment_log.trade_status).to eq "SUCCESS"
          expect(new_payment_log.trade_no).to eq trade_no
          expect(new_order.result).to eq "1颗星星购买成功"
          expect(new_order.status).to eq "SUCCESS"
          updated_user = Pandora::Models::User.find(user.id)
          expect(updated_user.vitality).to eq 1
          expect(updated_user.account.balance).to eq 1
        end

        it "should update VIP order status to be success" do
          order.update!(product: "VIP")
          order.update!(total_fee: 58)
          params = {
              "out_trade_no" => out_trade_no,
              "trade_status" => "TRADE_SUCCESS",
              "trade_no" => trade_no
          }
          subject.notify params
          new_payment_log = Pandora::Models::PaymentLog.find(payment_log.id)
          new_order = Pandora::Models::Order.find(order.id)
          expect(new_payment_log.trade_status).to eq "SUCCESS"
          expect(new_payment_log.trade_no).to eq trade_no
          expect(new_order.result).to eq "会员续费成功"
          expect(new_order.status).to eq "SUCCESS"
          updated_user = Pandora::Models::User.find(user.id)
          expect(updated_user.vitality).to eq 58
          expect(updated_user.account.balance).to eq 58
        end

        it "should update order status UNPAY if return_code is not SUCCESS" do
          params = {
              "out_trade_no" => out_trade_no,
              "trade_status" => "FAIL",
              "trade_no" => trade_no
          }
          subject.notify params
          new_payment_log = Pandora::Models::PaymentLog.find(payment_log.id)
          new_order = Pandora::Models::Order.find(order.id)
          expect(new_payment_log.trade_status).to eq "FAIL"
          expect(new_payment_log.trade_no).to eq trade_no
          expect(new_order.result).to eq "买家支付失败"
          expect(new_order.status).to eq "UNPAY"
        end
      end

      context "not first notify" do
        it "should not do anything and directly return success" do
          params = {
              "out_trade_no" => out_trade_no,
              "result_code" => "SUCCESS",
              "trade_no" => trade_no
          }
          order.update(:status => "FAIL")
          expect(subject.notify params).to eq ("success")
          expect_any_instance_of(Pandora::Services::UserService).not_to receive(:update_order)
          expect_any_instance_of(Pandora::Services::UserService).not_to receive(:update_payment_log)
        end
      end
    end

    context "verify fail" do
      before do
        allow(fake_ali_pay).to receive(:verify?).and_return(false)
      end

      it "should directly return sign fail" do
        expect(subject.notify({})).to eq ("FAIL")
      end
    end
  end
end