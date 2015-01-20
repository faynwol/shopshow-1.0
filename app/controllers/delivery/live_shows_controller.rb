class Delivery::LiveShowsController < Delivery::ApplicationController  

	before_action :find_live_show, except: [:index, :new, :create, :upload_preview, :preview_page, :fresh_page]
  before_action :admin_required, except: [:preview_page, :fresh_page] 


  def index
    @live_shows = LiveShow.order('created_at DESC')
  end

  def show    
    @products = @live_show.products.order('created_at DESC')
  end

  def new
    @live_show = LiveShow.new
  end

  def create    
  	@live_show = @current_admin.live_shows.build live_show_params
  	if @live_show.save
  	  redirect_to delivery_live_show_path(@live_show)
    else
      render :new
    end
  end

  def edit
  end

  def update        
    if @live_show.update_attributes(live_show_params)
      redirect_to delivery_live_shows_path
    else
      render :edit
    end
  end

  def open
  	@live_show.update_attribute(:status, 'onair')
  	redirect_to delivery_live_show_path(@live_show)
  end

  def close
  	@live_show.update_attributes!({status: 'closed', countdown: params[:countdown], close_time: Time.now})
    @live_show.jpush_notify_room_closed
  	redirect_to delivery_live_shows_path
  end

  # 默认人民币
  def clearing_price
    clearing_price = (params[:product_price].to_f * @live_show.exchange_rate.to_f).ceil
    render json: { clearing_price: clearing_price }
  end

  def shopping_list
    @order_items = @live_show.order_items
                             .select("*, sum(quantity) as quantity")
                             .joins(:order)
                             .includes(:sku, :product)
                             .where('orders.status = ?', Order.statuses[:paid])
                             .group("order_items.sku_id")
    
  end

  #===========================>
  #直播室预展页面
  def preview_page
    @products = LiveShow.where(subject: 'Costco Beta test Show 12/2014').first.products    
    render layout: false
  end

  def fresh_page
    @products = LiveShow.where(subject: 'Sephora 丝芙兰 Fresh专场').first.products    
    render layout: false    
  end

  #============================>

  private

  def live_show_params
    params.require(:live_show).permit(
      :subject, :description, :preview, 
      :start_time, :close_time,
      :html_url,
      :countdown, 
      :exchange_rate,
      :location
    )
  end

  def find_live_show  
  	@live_show = LiveShow.find params[:id]
  end

end