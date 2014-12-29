class AddOrderNoIntoOrders < ActiveRecord::Migration
  def change
  	add_column :orders, :order_no, "char(13)", after: :id
  end
end
