class Order < ActiveRecord::Base
  include PrimaryKeySecurity
  include ReadableStatus

  belongs_to :user
  has_many :order_items
  belongs_to :live_show, counter_cache: true
  belongs_to :recipient

  validates_numericality_of :amount, :original_amount

  enum status: [
    :pending,             # 待付款
    :cancel,              # 订单被取消
    :failed,              # 付款失败
    :paid,                # 已付款，待算运费
    :packaged,            # 已备货
    :freight,             # 已出运费，催缴运费
    :freight_paid,        # 已交运费
    :outbound,            # 已出库
    :transit_cn,          # 飞往中国
    :tax,                 # 已出税，催缴关税
    :tax_paid,            # 已缴关税
    :express,             # 已发国内快递
    :arrived,             # 已送达
    :finish               # 已完成
  ]

  # def recipient
  #   Recipient.find_by id: recipient_id
  # end

  def pay!(gateway = :balance)
    if (rest = user.balance - amount) < 0
      raise UserBalance::Not_Enough_Balance
    end

    balance = user.user_balance.update_attributes!(balance: rest)
    history = user.user_balance.histories.build
    history.user_id = user_id
    history.amount = amount
    history.history_type = 'consume'
    history.reason = "PAID"
    history.save!
    paid!
  end

  def cancelable?
    %w(pending failed).include? status
  end

  def carriage
    ws = 0
    self.order_items.each do |oi|    
      ws += oi.sku.weight.to_f * oi.quantity
    end
    
    ws = ws * 1000.0
    if ws == 0
      "无法估算此产品运费"
    elsif ws < 500
      30
    elsif ws % 100 > 0
      (ws / 100.0).ceil * 6
    else
      ws / 100.0 * 6
    end    
  end

  def notify_carriage          
    client = JPush::JPushClient.new(Settings.app_key, Settings.master_secret);    
    registration_id = self.user.devices.where("jpush_register_id <> ''").map(&:jpush_register_id)
    return if registration_id.blank?   
    payload = JPush::PushPayload.build(
     platform: JPush::Platform.all,
     audience: JPush::Audience.build(registration_id: registration_id),
     notification: JPush::Notification.build(
        alert: nil,
        ios: JPush::IOSNotification.build(
          alert: "您的订单编号为#{self.id}的订单需要缴纳运费#{self.carriage.to_f}元,请尽快缴费!",          
          badge: 0,
          sound: "happy"
        )
      )
    )
    client.sendPush(payload)      
  end


  def self.create_order_with_items(user, live_show_id, items, recipient_id, remark)
    transaction do
      order = user.orders.new
      order.live_show_id = live_show_id
      order.generate_secure_id!
      order.remark = remark

      items.each do |item|
        # product_id: id
        # quantity: count
        # specification: select

        product = Product.find item["id"]
        if product.clearing_price.blank?
          product.update_attributes!({ 
            clearing_price: (product.price.to_f * product.live_show.exchange_rate.to_f).ceil,
            clearing_currency: "RMB"
          })
        end

        if item[:select].blank?
          sku = product.default_sku
        else
          sku = product.find_or_create_sku_by! item[:select]
        end
        
        order_item = OrderItem.new
        order_item.sku_id = sku.id
        order_item.order_id = order.id
        order_item.product_id = product.id
        order_item.live_show_id = live_show_id
        order_item.quantity = item["count"].to_i
        order_item.save!
        order.original_amount ||= 0
        order.original_amount += product.clearing_price * order_item.quantity
      end

      order.recipient_id = recipient_id
      order.amount = order.original_amount
      order.save!
      order
    end
  end

end