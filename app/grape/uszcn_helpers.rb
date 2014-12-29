module Shopshow
  module UszcnAPIHelpers
    SECRET_KEY = '7aa7abd59bfd34ui'

    def authenticate!
      data_digest = params[:data_digest]
      content = params[:content]

      if data_digest.blank?
        error!('参数 [data_digest] 不能为空', 200)
      end 

      if content.blank?
        error!('参数 [content] 不能为空', 200)
      end

      if not data_digest == Digest::MD5.base64digest("#{content}#{SECRET_KEY}")
        error!('参数 [content] 不正确', 200)
      end

      begin
        MultiJson.load(content) 
      rescue => e
        error!('参数非法，无法解析', 200)
      end
    end
    
  end
end