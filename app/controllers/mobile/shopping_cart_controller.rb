class Mobile::ShoppingCartController < Mobile::AppController
  before_action :find_user
  before_action :find_live_show, only: [:goods, :confirm]
  
  def goods
    @goods = @user.goods_in_cart.where(live_show_id: @live_show.id).includes(:product, :sku).order('created_at DESC')
    @total_quantity = @goods.sum(:quantity)
    @total_amount = @goods.collect do |good|
      good.product.clearing_price * good.quantity
    end.sum    
  end

  def update_item
    cart_item = @user.goods_in_cart.where(sku_id: params[:sku_id]).first
    begin
      cart_item.quantity = params[:quantity].to_i
      cart_item.save!
      render json: { success: true }
    rescue Exception => e
      ExceptionNotifier.notify_exception e, env: request.env, 
                                            data: { message: "添加商品到购物车失败" }            
      render json: { success: false }
    end    
  end

  def remove
    begin
      good = @user.goods_in_cart.where(id: params[:good_id]).first
      good.destroy!
      render json: { success: true }
    rescue Exception => e
      ExceptionNotifier.notify_exception e, env: request.env, 
                                            data: { message: "删除购物车中商品失败" }      
      render json: { success: false, message: '删除失败了 >_<' }      
    end
  end

  def remove_selected
    begin
      goods = @user.goods_in_cart.where(id: params[:good_ids])
      goods.destroy_all
      render json: { success: true }
    rescue Exception => e
      ExceptionNotifier.notify_exception e, env: request.env, 
                                            data: { message: "删除购物车中商品失败" }      
      render json: { success: false, message: '删除失败了 >_<' }      
    end    
  end

  def confirm
    @goods = @user.goods_in_cart.where(id: params[:good_ids].split(','))
                                .includes(:product, :sku)
                                .order('created_at DESC')
    @total_quantity = @goods.sum(:quantity)
    @total_amount = @goods.collect do |good|
      good.product.clearing_price * good.quantity
    end.sum

    @recipient = if params[:recipient_id].blank?
      @user.default_recipient
    else
      Recipient.find params[:recipient_id]
    end

    items = @goods.collect do |good|
      {
        id: good.product_id,
        select: good.sku.prop.values.join(','),
        count: good.quantity
      }
    end

    @build_params = {
      live_show_id: @live_show.id,
      recipient_id: @recipient.try(:id),
      items: items,
      good_ids: @goods.map(&:id).join(',')
    }.to_query
  end 
end
