class Mobile::OrdersController < Mobile::AppController
  before_action :find_user
  before_action :find_live_show

  def index
    @orders = @user.orders.order('created_at DESC')
  end
end