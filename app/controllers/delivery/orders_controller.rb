class Delivery::OrdersController < Delivery::ApplicationController
  before_action :admin_required
  before_action :find_order, except: [:index]

  def index
    @live_show = LiveShow.find_by id: params[:live_show_id]     
    @live_show = LiveShow.where('status <> ?', 'pending').first if !@live_show.present?   
    inbounds = @live_show.inbounds
    @inbound_finish = inbounds.present? ? ( inbounds.first.status == 'finish' ) : false
    @orders = @live_show.orders.order('user_id DESC, created_at DESC').includes(:user, :order_items, :recipient)    
  end

  def check_prepare_products        
    live_show = @order.live_show
    live_show.inbounds.each do |ib|      
      ib.uszcn_query_inbound! #if Time.now - ib.updated_at > 30.minutes                            
    end

    inbounded_lists = live_show.merge_inbounds
    @order.order_items.each do |oi|
      #TODO 去掉已经出库的数量
      a = inbounded_lists[oi.sku_id.to_i].blank? ? 0 : inbounded_lists[oi.sku_id.to_i][:inbounded_quantity]
      render text: {abundant: false}.to_json and return if a < oi.quantity
    end
    shipmentfee = @order.carriage.to_i
    @order.update_attribute(:status, 'freight')
    @order.shipmentfee = shipmentfee
    @order.save!
    render text: {abundant: true}.to_json
  end

  def notify_carriage
    begin      
      @order.notify_carriage
      render text: {success: true}.to_json
    rescue => e      
      render text: {success: false}.to_json
    end
  end

  def notify_tax    
    outbound = Outbound.find_by order_id: @order.id
    outbound.notify_tax
    render text: {success: true}.to_json
  end  


  def find_order
    @order = Order.find_by id: params[:id]
  end

end
