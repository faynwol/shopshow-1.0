class AddColumnsToInbounds < ActiveRecord::Migration
  def change
    add_column :inbounds, :inbounded_quantity, :integer, after: :quantity, default: 0
    add_column :inbounds, :remark, :string, after: :inbounded_quantity
  end
end
