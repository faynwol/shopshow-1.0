class Mobile::OrdersController < Mobile::AppController
  before_action :find_user
  before_action :find_live_show

  def index
    @orders = @user.orders.order('created_at DESC')
  end

  def outbound_msg
    begin
      order = Order.find params[:order_id]
      render json: order.outbound_msg
    rescue => e
      render json: {status: '出错了哈，别乱搞！'}
    end
  end

end