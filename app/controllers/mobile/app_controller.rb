class Mobile::AppController < ApplicationController
  layout 'mobile'

  private

  def find_live_show
    @live_show = if params[:live_show_id].blank? || params[:live_show_id].length != 8
      LiveShow.first
    else
      LiveShow.find params[:live_show_id]
    end    
  end

  def find_user
    @user = User.find_by private_token: params[:token]
  end
end