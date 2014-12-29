class Cpanel::LiveShowsController < Cpanel::ApplicationController
  skip_before_action :login_required, only: :orders
  skip_before_action :admin_required, only: :orders
  before_action :find_live_show, only: [:show, :products, :orders, :edit, :update, :close]

  def index
    @live_shows = LiveShow.order('created_at DESC')
  end

  def show  
    @products = @live_show.products.order('created_at DESC')
    
    @orders = @live_show.orders.order('created_at DESC, user_id DESC').includes(:user).includes(:order_items)  

    @order_items = @live_show.order_items.select("*, sum(quantity) as quantity").joins(:order).where('orders.status = 3').group("order_items.sku_id")
  end

  def products
    @products = @live_show.products.order('created_at DESC')
    render layout: false
  end

  def new
    @live_show = LiveShow.new
  end

  def create
    @live_show = LiveShow.new live_show_params
    @live_show.generate_secure_id!
    @live_show.user_id = current_user.id

    if @live_show.save
      redirect_to cpanel_live_shows_path
    else
      render :new
    end
  end

  def edit        
  end

  def update
    @live_show.update_attributes(live_show_params)
    redirect_to cpanel_live_shows_path
  end

  def close
    @live_show.update_attributes!({ :closed => true })
    redirect_to cpanel_live_shows_path
  end

  def choose_material
    @materials = Material.where(live_show_id: params[:live_show_id])
                         .where(material_type: %w(jpeg jpg png gif))   
    render :layout => false
  end
  
  private

  def find_live_show
    @live_show = LiveShow.find params[:id]
  end

  def live_show_params
    params.require(:live_show).permit(
      :subject, :description, :preview, 
      :start_time, :close_time,
      :html_url,
      :countdown, :exchage_rate
    )
  end
end