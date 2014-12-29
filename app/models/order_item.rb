class OrderItem < ActiveRecord::Base
  belongs_to :order
  belongs_to :product
  belongs_to :sku
  belongs_to :live_show

  validates_numericality_of :quantity, only_integer: true, greater_than_or_equal_to: 1  

  def calc_in_total
    quantity * product.price
  end

end
