class Sku < ActiveRecord::Base
  has_many :order_items
  belongs_to :product
  has_and_belongs_to_many :inbounds, join_table: :inbound_skus
  has_many :inbound_skus

  validates_uniqueness_of :sku_id
  validates_uniqueness_of :prop, scope: :sku_id, allow_blank: true

  store :prop  

  before_create do
    self.sku_id = "#{product_id}#{SecureRandom.hex(2)}"
  end

  def prop_to_text
    text = []
    (self.prop || {}).each_pair do |k, v|
      text << "#{k}:#{v}"
    end
    text.join ","

    # text.presence || "默认规格"
  end

  def weight
    w = read_attribute :weight
    if w.to_f.zero?
      return "重量未出"
    end
    w
  end

  def add_to_cart_of(user, quantity)
    cart = user.goods_in_cart.find_or_initialize_by(sku_id: self.id)
    cart.product_id = self.product_id
    cart.sku_id = self.id
    cart.live_show_id = self.product.live_show_id
    cart.quantity = cart.quantity.to_i + quantity.to_i
    cart.save!
    cart    
  end
end
