class Mobile::OrdersController < Mobile::AppController
  before_action :find_user
  before_action :find_live_show
  skip_before_filter :verify_authenticity_token , only: [:index,:handle_alipay_notify]
  def index
    if request.post?
      verify_alipay_and_pay_order
    end
    @orders = @user.orders.order('created_at DESC')
  end
  
  def handle_alipay_notify
    Rails.logger.info("handle_alipay_notify:"+request.body.string)
    render :text=>'success'
  end
  def verify_alipay_and_pay_order
        request_body = Base64.decode64(request.body.string)
      order_id = params[:order_id]
      p "==============================================================>"
      p request_body
      sign = request_body.match(/&sign="([^"]*)"/)
      if sign.blank?
        return
      else
        sign = sign.captures[0]
        return if sign.blank?
      end
      public_key = OpenSSL::PKey::RSA.new(Base64.decode64("MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQCnxj/9qwVfgoUh/y2W89L6BkRAFljhNhgPdyPuBV64bfQNN1PjbCzkIM6qRdKBoLPXmKKMiFYnkd6rAoprih3/PrQEB/VsW8OoM8fxn67UDYuyBTqA23MML9q1+ilIZwBC2AQ2UBVOrFXfFl75p6/B5KsiNG9zpgmLCUYuLkxpLQIDAQAB"))
    decoded_sign = Base64.decode64(sign)
    rsa_verify_result = public_key.verify('SHA1',request_body,decoded_sign)
    p "==============================================================>"
    p rsa_verify_result
    p "<=============================================================="
    pain_txt_idx = request_body.gsub(/&sign_type="([^"]*)"/,'').gsub(/&sign="([^"]*)"/,'')
    p pain_txt_idx.force_encoding("UTF-8")
    p "<=============================================================="
    
    #支付宝上线后，要改成正确的
    if !rsa_verify_result
      order_id_from_alipay = request_body.match(/&out_trade_no="([^"]*)"/)
      order_id_from_alipay = order_id_from_alipay.captures[0] if !order_id_from_alipay.blank?
      total_fee_from_alipay = request_body.match(/&total_fee="([^"]*)"/)
      total_fee_from_alipay = total_fee_from_alipay.captures[0] if !total_fee_from_alipay.blank?
      subject_from_alipay = request_body.match(/&subject="([^"]*)"/)
      subject_from_alipay = subject_from_alipay.captures[0].force_encoding("UTF-8") if !subject_from_alipay.blank?
      p subject_from_alipay
      p subject_from_alipay == "尚品秀运费"
      p "<=============================================================="
      return if order_id_from_alipay.blank? || total_fee_from_alipay.blank? || order_id_from_alipay != order_id
      order = Order.find(order_id)
      if subject_from_alipay == "尚品秀运费"
        return if  (order.shipmentfee*100).to_i != (total_fee_from_alipay.to_f*100).to_i
        return if !order.freight?
        order.update_attribute(:status, 'freight_paid')
      else
        return if  (order.amount*100).to_i != (total_fee_from_alipay.to_f*100).to_i
        return if !order.cancelable?
        order.pay!
      end
    else
      return
    end

  end
end
