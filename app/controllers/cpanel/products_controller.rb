class Cpanel::ProductsController < Cpanel::ApplicationController
  def index
  end

  def show
    @product = Product.find params[:id]
    render layout: false
  end

  def new
  end

  def create
    begin
      ActiveRecord::Base.transaction do
        material_ids = product_params[:picture_ids].split(',')
        materials = Material.where(id: material_ids)
        price = product_params.delete(:price).to_f
        
        @product = current_user.products.build product_params
        @product.price = price
        @product.cover_id = material_ids.first
        @product.materials = materials
        @product.content[:specifications] = @product.props
        @product.save!   
      end

      render json: { success: true, product: @product }
    rescue => e
      render json: { success: false }
    end
  end

  def edit
    @product = Product.find params[:id]
  end

  def update
    @product = Product.find params[:id]
    begin
      Product.transaction do
        material_ids = params[:picture_ids].split(',')
        materials = Material.where(id: material_ids)
        
        @product.materials = materials
        @product.update_attributes! product_params
        redirect_to cpanel_live_show_path(@product.live_show_id), notice: "Update product succeed."
      end
    rescue => e
      render :edit
    end
  end

  def publish
    @product = Product.find params[:id]
    @product.published!

    render json: @product
  end

  private

  def product_params
    # params.require(:product).permit(
    #   :props,
    #   :live_show_id, :name_en, :name_cn, :price, :currency, :status,
    #   :description, :tax_rate, :brand_cn, :brand_en, :picture_ids
    # )
    params.require(:product).permit!
  end
end