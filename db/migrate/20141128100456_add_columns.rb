class AddColumns < ActiveRecord::Migration
  def change
    add_column :inbounds, :live_show_id, "char(8)", before: :created_at
    add_column :outbounds, :order_id, "char(8)", before: :created_at
  end
  
end
