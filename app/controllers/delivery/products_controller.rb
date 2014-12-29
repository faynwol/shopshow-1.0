class Delivery::ProductsController < Delivery::ApplicationController
  before_action :admin_required  
  before_action :find_live_show, only: [:new, :create, :edit, :update]

  def index
  end

  def new
    @product = @live_show.products.build
    find_materials
    (2 -  @product.specifications.size).times do
      @product.specifications.build
    end    
  end

  def create
    ActiveRecord::Base.transaction do
      @product = @live_show.products.build product_params
      @product.author_id = @current_admin.id
      set_materials
      set_cover

      if @product.save
        publish_product!
        redirect_to delivery_live_show_path(@live_show)
      else
        (2 -  @product.specifications.size).times do
          @product.specifications.build
        end
        render :new
      end
    end
  end

  def edit
    @product = Product.find params[:id]
    find_materials
    (2 -  @product.specifications.size).times do
      @product.specifications.build
    end     
  end

  def update
    Product.transaction do
      @product = Product.find params[:id]

      if @product.update_attributes(product_params)
        set_materials
        set_cover
        publish_product!
        redirect_to delivery_live_show_path(@live_show)
      else
        (2 -  @product.specifications.size).times do
          @product.specifications.build
        end        
        render :edit 
      end
    end
  end

  private

  def product_params
    params.require(:product).permit(
      :id, :cover_id,
      :name_en, :description, :price, :weight,
      :weight_unit, :live_show_id,
      :picture_ids, :status, specifications_attributes: [:id, :name, :value]
    )
  end

  def find_live_show
    @live_show = LiveShow.find params[:live_show_id]
  end

  def find_materials
    @materials = Material.where(id: @product.picture_ids.split(",")).order('created_at desc')
  end

  def set_materials
    find_materials
    @product.materials = @materials
  end

  def set_cover
    if @product.cover_id.blank?
      @product.cover_id = @materials.first.try(:id)
    end    
  end

  def publish_product!
    if @product.published_at.blank? and @product.published?
      @product.publish! 
    end    
  end
end