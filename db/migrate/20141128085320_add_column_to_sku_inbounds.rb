class AddColumnToSkuInbounds < ActiveRecord::Migration
  def change
    add_column :inbound_skus, :inbounded_quantity, :integer, default: 0, after: :quantity
  end
end
