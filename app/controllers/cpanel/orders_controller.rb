class Cpanel::OrdersController < Cpanel::ApplicationController
  def index
    @orders = Order.order('created_at DESC')
  end
end