class Delivery::MessagesController < Delivery::ApplicationController
  before_action :admin_required  
  before_action :find_live_show

  def index
    @messages = @live_show.messages.includes(:user).order("messages.created_at ASC")
    @messages = @messages.paginate(per_page: 20, page: params[:page])
  end 

  private

  def find_live_show
    @live_show = LiveShow.find params[:live_show_id]
  end  
end