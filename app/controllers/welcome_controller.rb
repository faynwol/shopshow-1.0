class WelcomeController < ApplicationController
  def index
    @recipient = Recipient.new
  end

  # temp 
  def update_avatar
    current_user.avatar = params[:avatar]    
    current_user.save!
    redirect_to root_path
  end

  def update_recipient
    @recipient = current_user.recipients.build params.require(:recipient).permit!
    @recipient.default = true
    if @recipient.save
      redirect_to root_path
    else
      render :index
    end    
  end
end