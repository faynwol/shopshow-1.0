class CreateInboundSkus < ActiveRecord::Migration
  def change
    create_table :inbound_skus do |t|
      t.belongs_to :inbound
      t.belongs_to :sku
      t.integer :quantity
      t.datetime :created_at
    end
  end
end
