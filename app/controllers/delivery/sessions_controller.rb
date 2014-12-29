class Delivery::SessionsController < Delivery::ApplicationController
  layout false
  before_action :no_login_required, only: [:new, :create]

  def new
  end

  def create
    @admin = User.auth(params[:login], params[:password])

    if @admin && @admin.admin?
      login_as @admin
      redirect_to delivery_root_path
    else
      flash[:warning] = "帐号或者密码错误"
      redirect_to delivery_login_path
    end    
  end

  def destroy
    logout
    flash[:warning] = "您已登出管理后台"
    redirect_to delivery_login_path
  end  
end