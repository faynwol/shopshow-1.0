class CreateProductSpecifications < ActiveRecord::Migration
  def change
    create_table :product_specifications do |t|
      t.column :product_id, "char(8)", null: false
      t.integer :parent_id, default: 0
      t.string :name, null: false
      t.timestamps
    end

    add_index :product_specifications, :product_id
    add_index :product_specifications, :parent_id
  end
end
