class AlterTokenTable < ActiveRecord::Migration
  def change
    remove_index :tokens, :id
    change_column :tokens, :id, :primary_key
    add_column :tokens, :body, :string, null: false, after: 'user_id' 
  end
end
