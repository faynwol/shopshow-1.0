class AddTaxIntoOutbound < ActiveRecord::Migration
  def change
  	add_column :outbounds, :tax, :float, default: 0.0, after: 'order_id'
  	add_column :outbounds, :has_tax, :boolean, default: false
  end
  
end
