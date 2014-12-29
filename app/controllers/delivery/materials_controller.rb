class Delivery::MaterialsController < Delivery::ApplicationController
  before_action :admin_required  
  before_action :find_live_show

  def create
    material = @live_show.materials.build
    material.user_id = @current_admin.id
    material.material_type = params[:material].content_type.split('/').last.downcase
    material.resource = params[:material]
    state = material.save
    render json: { success: state, material: material }    
  end

  private

  def find_live_show
    @live_show = LiveShow.find params[:live_show_id]
  end
end