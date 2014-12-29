class AddJpushRegisterIdIntoUserDevices < ActiveRecord::Migration
  def change
  	add_column :user_devices, :jpush_register_id, :string, default: nil, after: 'user_id'
  end
  
end
