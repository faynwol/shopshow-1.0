class AddWeightAndUnitToProduct < ActiveRecord::Migration
  def change
    add_column :products, :weight, :float, default: nil, after: 'brand_en'
    add_column :products, :weight_unit, :string, default: nil, after: 'weight'
  end
end
