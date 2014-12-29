class Cpanel::FaqsController < Cpanel::ApplicationController
	skip_before_action :login_required, :admin_required
	layout false

  def faq1   
  end
  
  def faq2
  end

  def faq3   
  end    

end