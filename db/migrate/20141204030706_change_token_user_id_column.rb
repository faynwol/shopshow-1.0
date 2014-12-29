class ChangeTokenUserIdColumn < ActiveRecord::Migration
  def change
    change_column :tokens, :user_id, :string, null: true
  end
end
