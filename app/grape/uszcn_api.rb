
require 'uszcn_helpers'

module Shopshow

  class Uszcn < Grape::API
    prefix :uszcn
    default_error_formatter :json
    format :json
    content_type :json, 'application/json;charset=utf-8'

    SECRET_KEY = '7aa7abd59bfd34ui'

    rescue_from ActiveRecord::RecordNotFound  do |e|
      Rack::Response.new({ data: nil, error: e.message }.to_json, 404).finish
    end

    formatter :json, lambda { |object, env|               
      { success: true, data: object }.to_json
    }

    error_formatter :json, lambda { |message, backtrace, options, env|  
      { error: message, success: false }.to_json        
    }

    helpers UszcnAPIHelpers

    before do
      params.each { |k, v| v.force_encoding(Encoding::UTF_8) if v.is_a?(String) } 
      Rails.logger.info params
    end    
    

    post :notify do      
      # data_digest = params[:data_digest]
      # content = params[:content]

      # if data_digest.blank?
      #   error!('data_digest is blank', 200)
      # end

      # if content.blank?
      #   error!('content is blank', 200)
      # end

      # unless data_digest == Digest::MD5.base64digest("#{content}#{SECRET_KEY}")
      #   error!('data_digest is incorrect', 200)
      # end

      # ret = MultiJson.load(content) rescue {}

      # if ret.blank?
      #   error!('content is incorrect', 200)
      # else
      #   ret
      # end
    end

    #入库通知
    post :finish_inbound_notify do 
      puts params.inspect
      {success: true}    
    end

    #出税通知
    post :tax_notify do 
      params = authenticate!
      outbound = Outbound.find_by channel_outbound_no: params["sc_code"]
      outbound.update_attributes(tax: params["custom_duty"], has_tax: true)      
    end
    
  end
end