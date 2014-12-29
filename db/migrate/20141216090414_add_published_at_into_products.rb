class AddPublishedAtIntoProducts < ActiveRecord::Migration
  def change
  	add_column :products, :published_at, :datetime, default: nil, after: 'content'
  end
end
