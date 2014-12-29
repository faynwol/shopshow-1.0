class InboundSku < ActiveRecord::Base
  belongs_to :sku
  belongs_to :inbound

  def product
    sku.product
  end

  def price
    product.price
  end

  def calc_in_total
    product.price * quantity
  end
end
