class Delivery::InboundsController < Delivery::ApplicationController
  before_action :admin_required  
  before_action :find_live_show, only: [:new]
  before_action :find_inbound, only: [:show, :query]

  def index
    @inbounds = Inbound.order('created_at DESC')
  end

  def show
    @inbound_skus = @inbound.inbound_skus.includes(:sku, :inbound).order('created_at DESC')
  end

  def new
    @live_shows = LiveShow.all
    if @live_show.present?
      @products = @live_show.products.order('created_at DESC')
      @orders = @live_show.orders.order('created_at DESC, user_id DESC').includes(:user, :order_items)  
      @order_items = @live_show.order_items
                               .select("*, sum(quantity) as quantity")
                               .joins(:order)
                               .includes(:sku, :product)
                               .where('orders.status = ?', Order.statuses[:paid])
                               .group("order_items.sku_id")
    end
  end

  def create
    ActiveRecord::Base.transaction do
      channel = Channel.default
      inbound = channel.inbounds.build
      inbound.status = 0
      inbound.live_show_id = params[:live_show_id]
      inbound.save!

      skus = params[:skus]
      skus.each do |k, v|
        i_s = inbound.inbound_skus.build      
        i_s.sku_id = v[:sku_id]
        i_s.quantity = v[:amount].to_i
        i_s.save!
      end

      inbounded = skus.values.sum { |h| h[:amount].to_i }
      inbound.update_attributes!(:quantity => inbounded)
      inbound.notify_channel_inbound
    end

    render json: { success: true }
  end

  def query
    @inbound.query_channel_inbound!
    redirect_to delivery_inbounds_path
  end

  private

  def find_inbound
    @inbound = Inbound.find_by id: params[:id]
  end

  def find_live_show
    @live_show = LiveShow.find_by id: params[:live_show_id]
  end
end