class AddUserCartTable < ActiveRecord::Migration
  def change
    create_table :user_goods_in_carts do |t|
      t.column :user_id, 'char(8)', null: false
      t.column :live_show_id, 'char(8)', null: false
      t.belongs_to :sku
      t.belongs_to :product
      t.integer :quantity
      t.datetime :created_at
    end

    add_index :user_goods_in_carts, :user_id
    add_index :user_goods_in_carts, :live_show_id
  end
end