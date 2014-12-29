class Cpanel::MaterialsController < Cpanel::ApplicationController
  def create
    material = current_user.materials.build
    material.live_show_id = params[:live_show_id]
    material.material_type = params[:material].content_type.split('/').last.downcase
    material.resource = params[:material]
    state = material.save

    render json: { success: state, material: material }
  end
end