module Shopshow
  module APIHelpers

    def logger
      Shopshow::API.logger
    end

    def current_user
      @current_user ||= User.find_by(private_token: params[:token])
    end

    def current_user=(new_user)
      @current_user = new_user
    end

    def authenticate!
      if params[:token].blank? || !current_user
        error!('401 Unauthorized', 401)
      end
    end

    def record_device
      device = current_user.devices.where(device_token: params[:device_token]).first
      if device.nil?
        device = current_user.devices.build
        device.jpush_register_id = params[:jpush_register_id]
        device.device_token = params[:device_token]
        device.device_name = params[:device_name]
        device.os = params[:os]
        device.os_version = params[:os_version]
        device.client_version = params[:client_version]      
        device.save!
      else
        device.update_attributes({
          jpush_register_id: params[:jpush_register_id],
          device_token: params[:device_token],
          device_name: params[:device_name],
          os: params[:os],
          os_version: params[:os_version],
          client_version: params[:client_version]
        })
      end
    end

    def version(version_number)
      Gem::Version.new version_number
    end
  end
end
