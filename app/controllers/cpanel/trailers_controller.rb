class Cpanel::TrailersController < Cpanel::ApplicationController
	layout false

  skip_before_action :login_required
  skip_before_action :admin_required
	
  def costco    
  end

  def next
  end

end