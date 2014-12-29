class AddColumnsToProductSpecs < ActiveRecord::Migration
  def change
    add_column :product_specifications, :value, :string, after: 'name'
  end
end
