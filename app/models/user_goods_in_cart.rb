class UserGoodsInCart < ActiveRecord::Base
  belongs_to :user
  belongs_to :live_show
  belongs_to :sku 
  belongs_to :product

end