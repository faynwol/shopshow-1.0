class Delivery::ApplicationController < ActionController::Base
  layout 'delivery'
  helper_method :admin_login?, :current_admin

  private

  class AdminAccessDenied < Exception; end

  def admin_required
    unless admin_login?
      flash[:warning] = "请先登录"
      redirect_to delivery_login_path
    end    
  end

  def admin_login?
    !!current_admin
  end

  def current_admin
    @current_admin ||= login_from_session unless defined?(@current_admin)
    @current_admin
  end

  def login_as(admin)
    session[:admin_id] = admin.id
    @current_admin = admin
  end

  def logout
    session.delete :admin_id
    @current_admin = nil
  end

  def login_from_session
    return nil if session[:admin_id].blank?
    begin
      User.find(session[:admin_id]) 
    rescue
      session[:admin_id] = nil
    end 
  end

  def no_login_required
    if admin_login?
      redirect_to delivery_root_url
    end
  end  
end