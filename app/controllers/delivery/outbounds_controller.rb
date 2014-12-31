class Delivery::OutboundsController < Delivery::ApplicationController
  before_action :admin_required
  
  def create 
    ActiveRecord::Base.transaction do
      begin
        order = Order.find_by id: params[:order_id]
        ib = Inbound.find_by live_show_id: order.live_show_id
        ob = Outbound.new
        ob.inbound_id = ib.id
        ob.order_id = order.id
        ob.outbound_no = ''
        ob.save!        
        raise '出库出错!' if ob.notify_uszcn!.blank?
        
        success = true
      rescue => e
        raise e
        success = false
        raise ActiveRecord::Rollback        
      end
      render text: {success: true}.to_json
    end
    
  end

  def query
    outbound = Outbound.find_by id: params[:id]    
    ret = outbound.query_shopshow_outbound    
    
    Rails.logger.info ret.inspect
    Rails.logger.info "***********************"        
    if ret["success"]
      order = Order.find_by id: outbound.order_id
      ActiveRecord::Base.transaction do 
        if !ret["data"]["outbound_code"].blank?
          order.update_attributes! status: 'outbound'
        end
        outbound.update_attributes! outbound_no: ret["data"]["outbound_code"]
        render html: Outbound.format_outbound_state(ret["data"]["item_list"])
      end
    else
      render html: "订单出库异常！请联系技术人员!"
    end  

          
  end

end