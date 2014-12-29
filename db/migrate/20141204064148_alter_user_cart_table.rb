class AlterUserCartTable < ActiveRecord::Migration
  def change
    change_column :user_goods_in_carts, :product_id, 'char(8)', null: false
  end
end
