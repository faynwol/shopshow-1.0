class AddLocationIntoLiveShow < ActiveRecord::Migration
  def change
  	add_column :live_shows, :location, :string, default: nil, after: 'subject'
  end
end
