class CreateOutboundSkus < ActiveRecord::Migration
  def change
    create_table :outbound_skus do |t|
      t.belongs_to :outbound
      t.belongs_to :sku
      t.integer :quantity      
      t.datetime :created_at      
    end
  end
end
