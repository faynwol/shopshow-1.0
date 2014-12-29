class Delivery::IndexController < Delivery::ApplicationController
  # before_action :admin_required  

  def dashboard
    redirect_to delivery_live_shows_path
  end
end