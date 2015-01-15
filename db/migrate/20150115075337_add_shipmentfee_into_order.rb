class AddShipmentfeeIntoOrder < ActiveRecord::Migration
  def change
    add_column :orders, :shipmentfee, :decimal,precision: 16, scale: 3, after: 'amount'    
  end
end
