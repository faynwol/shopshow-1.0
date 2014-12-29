class AddColumnsToTokens < ActiveRecord::Migration
  def change
    add_column :tokens, :phone, :string, default: nil, after: 'body'
    add_column :tokens, :email, :string, default: nil, after: 'phone'
  end
end
