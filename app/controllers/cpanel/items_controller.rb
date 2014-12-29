class Cpanel::ItemsController < Cpanel::ApplicationController
  def index
    @order = Order.find params[:order_id]
    @items = @order.order_items.order('created_at DESC')
  end
end