#encoding:utf-8
require 'common/logging'
require 'common/error'

class BaseController
  include Common::Logging
  SUCCESS = 'SUCCESS'
  ERROR = 'ERROR'
  FAIL = 'FAIL'
  BEAUTYSHOW = 'BEAUTYSHOW'
  DESIGNER = 'DESIGNER'
  CONSUME = "CONSUME"
  DONATE = "DONATE"
  RECHARGE = "RECHARGE"
  TRADE_FINISHED = "TRADE_FINISHED"
  TRADE_SUCCESS = "TRADE_SUCCESS"
  UNKNOW_PRODUCT ='UNKNOW_PRODUCT'
  UNPAY ="UNPAY"
  PAID ="PAID"
  CREATED ="CREATED"

  def self.call method, params
    self.new.execute method, params
  end

  def execute method, params
    begin
      check_args params
      send(method, *params)
    rescue Common::Error => e
      logger.error e.message
      error e.message
    rescue => e
      log_error("系统内部错误.", e)
      error '对不起,系统错误,请稍后再试.'
    end
  end

  private
  def error message
    {
        status: ERROR,
        message: message
    }
  end

  def success
    {
        status: SUCCESS,
        message: "操作成功"
    }
  end

  def check_args args
    raise Common::Error.new("参数传递错误.") if args.any? { |arg| arg.nil? }
  end

end