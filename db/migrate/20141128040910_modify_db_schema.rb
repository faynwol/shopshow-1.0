class ModifyDbSchema < ActiveRecord::Migration
  def change
    remove_column :inbounds, :sku_id
    add_column :inbounds, :status, :integer, after: :quantity

    remove_column :outbounds, :inbound_no
    remove_column :outbounds, :sku_id
    remove_column :outbounds, :quantity
    add_column :outbounds, :inbound_id, :integer, after: :channel_outbound_no
  end
end
