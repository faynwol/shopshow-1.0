class Mobile::OrdersController < Mobile::AppController
  before_action :find_user
  before_action :find_live_show
  skip_before_filter :verify_authenticity_token , only: [:index,:handle_alipay_notify,:outbound_msg]
  def index
    if request.post?
      verify_alipay_and_pay_order
    end
    @orders = @user.orders.order('created_at DESC')
  end
    #除去数组中的空值和签名参数
  def para_filter paras = {}
    new_paras = {}
    paras.each{|key,value|
      if key != :sign && key != :sign_type && key != 'sign' && key != 'sign_type' && value != '' && value != nil
        new_paras[key] = value
      end
    }
    return new_paras
  end
    #把数组所有元素，排序后按照“参数=参数值”的模式用“&”字符拼接成字符串
  def create_link_string hash, sort = true
    result_string = ''
    #是否排序
    if sort
      hash = hash.sort
    end

    hash.each{|key,value|
      result_string += (key.to_s + '=' + value.to_s + '&')
    }
    #去掉末尾的&
    result_string = result_string[0, result_string.length - 1]
    return result_string
  end  
  def verify_alipay_sign for_sign_string,signed_string
    openssl_public = OpenSSL::PKey::RSA.new(Base64.decode64("MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQCnxj/9qwVfgoUh/y2W89L6BkRAFljhNhgPdyPuBV64bfQNN1PjbCzkIM6qRdKBoLPXmKKMiFYnkd6rAoprih3/PrQEB/VsW8OoM8fxn67UDYuyBTqA23MML9q1+ilIZwBC2AQ2UBVOrFXfFl75p6/B5KsiNG9zpgmLCUYuLkxpLQIDAQAB"))
    #生成SHA1密钥串
    digest = OpenSSL::Digest::SHA1.new
    #openssl验证签名
    openssl_public.verify(digest, Base64.decode64(signed_string), for_sign_string)
  end
  def handle_alipay_notify
    Rails.logger.info(request.body.inspect)
    Rails.logger.info(request.body.class)
    Rails.logger.info(request.body.methods)
    Rails.logger.info("handle_alipay_notify:"+request.body.string)
    in_hash         = para_filter request.POST    #sort_hash       = in_hash.sort
    for_sign_string = create_link_string(in_hash,true)
    sign = params[:sign]
    verify_result = verify_alipay_sign(for_sign_string,sign)
    order_id_from_alipay = params[:out_trade_no]
    rmb_fee  = params[:total_fee]
    pay_type = order_id_from_alipay.split('_')[0]
    order_id = order_id_from_alipay.split('_')[1]
    if verify_result
      order = Order.find(order_id)
      total_fee_from_alipay = rmb_fee
      p total_fee_from_alipay
      #p (order.shipmentfee*100).to_i == (total_fee_from_alipay.to_f*100).to_i && order.freight?
      #p (order.amount*100).to_i == (total_fee_from_alipay.to_f*100).to_i &&order.cancelable?
      if pay_type == "shipmentfee"
         if  order.freight?
          p "==============================================================>"
          p "回调收取运费"
           order.update_attribute(:status, 'freight_paid')
         end
      else
        if  order.cancelable?
          order.pay!
          p "==============================================================>"
          p "回调收取货款"
        end
      end
    end
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
      #public_key = Op
      #enSSL::PKey::RSA.new(Base64.decode64("MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQCnxj/9qwVfgoUh/y2W89L6BkRAFljhNhgPdyPuBV64bfQNN1PjbCzkIM6qRdKBoLPXmKKMiFYnkd6rAoprih3/PrQEB/VsW8OoM8fxn67UDYuyBTqA23MML9q1+ilIZwBC2AQ2UBVOrFXfFl75p6/B5KsiNG9zpgmLCUYuLkxpLQIDAQAB"))
    #decoded_sign = Base64.decode64(sign)
    pain_txt_idx = request_body.force_encoding("UTF-8")
    pain_txt_idx = pain_txt_idx.gsub(/&sign_type="([^"]*)"/,'').gsub(/&sign="([^"]*)"/,'')
    

    rsa_verify_result = verify_alipay_sign(pain_txt_idx,sign)
    p "==============================================================>"
    p rsa_verify_result
    p "<=============================================================="
    p pain_txt_idx.force_encoding("UTF-8")
    p "<=============================================================="
    
    #支付宝上线后，要改成正确的
    if rsa_verify_result
      order_id_from_alipay = request_body.match(/&out_trade_no="([^"]*)"/)
      order_id_from_alipay = order_id_from_alipay.captures[0] if !order_id_from_alipay.blank?
      pay_type = order_id_from_alipay.split('_')[0]
      order_id_from_alipay = order_id_from_alipay.split('_')[1]
      total_fee_from_alipay = request_body.match(/&rmb_fee="([^"]*)"/)
      total_fee_from_alipay = total_fee_from_alipay.captures[0] if !total_fee_from_alipay.blank?
      subject_from_alipay = request_body.match(/&subject="([^"]*)"/)
      subject_from_alipay = subject_from_alipay.captures[0].force_encoding("UTF-8") if !subject_from_alipay.blank?
      return if order_id_from_alipay.blank? || total_fee_from_alipay.blank? || order_id_from_alipay != order_id
      order = Order.find(order_id)
      if pay_type == "shipmentfee"
        return if  (order.shipmentfee*100).to_i != (total_fee_from_alipay.to_f*100).to_i
        return if !order.freight?
        p "==============================================================>"
        p "同步收取运费"
        order.update_attribute(:status, 'freight_paid')
      else
        return if  (order.amount*100).to_i != (total_fee_from_alipay.to_f*100).to_i
        return if !order.cancelable?
        order.pay!
        p "==============================================================>"
        p "同步收取货款"

      end
    else
      return
    end
  end
  
  def outbound_msg
    begin
      order = Order.find params[:order_id]
      puts order.inspect
      puts "****"
      render json: order.outbound_msg
    rescue => e
      puts e.inspect
      render json: {status: '查询物流失败，请联系店小二'}
    end
  end
end
