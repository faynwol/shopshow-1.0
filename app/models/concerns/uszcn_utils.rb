module UszcnUtils
  extend ActiveSupport::Concern

  SECRET_KEY                      = '7aa7abd59bfd34ui'
  INBOUND_PATH                    = "create_shopshow_inbound"
  QUERY_INBOUND_PATH              = "query_shopshow_inbound"

  OUTBOUND_PATH                   = "create_shopshow_outbound"
  QUERY_OUTBOUND_PATH             = "query_uszcn_outbound"

  CREAT_WAYBILL_REMARK            = "create_waybill_remark"
  UPDATE_SHOPSHOW_OUTBOUND_ID_PIC = "update_shopshow_outbound_id_pic"

  REQUEST_TIMEOUT                 = 180

  # 一些静态方法
  class << self
    def host
      host = if Rails.env.production?
        "http://cn.uszcn.com"
      else
        "http://cn.uszcn.local:3000"
      end
      "#{host}/shopshow_api"      
    end

    def g_inbound_no!
      inbounds_count = ActiveRecord::Base::Inbound.count + 1
      "SS#{Time.now.strftime('%y%m%d')}#{inbounds_count.to_s.rjust(5, '0')}"
    end

    def g_outbound_no!
      outbounds_count = ActiveRecord::Base::Outbound.count + 1
      "SC#{Time.now.strftime('%y%m%d')}#{outbounds_count.to_s.rjust(5, '0')}"
    end
  end  

  # 一些公用方法
  module Utils
    def digest content      
      Digest::MD5.base64digest("#{content}#{SECRET_KEY}")
    end

    def client      
      @client ||= RestClient::Resource.new UszcnUtils.host, timeout: REQUEST_TIMEOUT
    end

    def run_request path, content = {}
      data_digest = digest content
      params = { data_digest: data_digest, content: content }      
      response = client[path].post params
      MultiJson.load response
    end    
  end

  # 入库相关方法
  module Inbound
    include Utils

    def uszcn_notify_inbound
      item_list = self.inbound_skus.collect do |is|
        {
          lu_category_id:     '',
          name_cn:            (is.product.description || is.product.name_cn).truncate(45),
          name_en:            is.product.name_en.truncate(45),        
          brand_cn:           is.product.brand_cn,
          brand_en:           is.product.brand_en,        
          model_cn:           is.sku.prop_to_text,
          model_en:           is.sku.prop_to_text,        
          amount:             is.quantity.to_i,
          cover:              is.product.cover.resource_url,
          unit_price:         is.product.price,
          third_party_code:   is.sku.sku_id,
          sku:                ""          
        }
      end

      params =  { ss_code: self.channel_inbound_no, item_list: item_list }.to_json

      begin
        run_request INBOUND_PATH, params
      rescue Exception => e
        ExceptionNotifier.notify_exception e, env: request.env, data: { message: "通知入库失败" }        
        self.update_attribute :status, "failed"
        {}
      end
    end

    def uszcn_query_inbound!      
      params = { ss_code: self.channel_inbound_no }.to_json
      response = run_request QUERY_INBOUND_PATH, params    

      ActiveRecord::Base.transaction do
        if response["success"]
          grand_total = 0
          response["data"]["item_list"].each do |item|
            grand_total += item["check_amount"]
            sku = Sku.find_by(sku_id: item["third_party_code"])
            inbound_sku = inbound_skus.where(sku_id: sku.id).first
            inbound_sku.inbounded_quantity = item["check_amount"]
            inbound_sku.save!
            sku.weight = item["unit_weight"]
            sku.save!        
          end
          if response["data"]["state"] == "FINISHED"
            self.status = "finish"
            self.inbounded_quantity = grand_total
            self.save!
          end      
        end
      end   
    end    
  end

  # 出库相关方法
  module Outbound
    include Utils

    def notify_uszcn!
      order = Order.find_by id: self.order_id
      order_items = order.order_items
      user = order.user
      order.status = "outbound"
      order.save!

      recipient = user.default_recipient
      inbound = ActiveRecord::Base::Inbound.find_by id: self.inbound_id

      item_list = order_items.collect do |item|
          {
            ss_code: inbound.channel_inbound_no,
            third_party_code: item.sku.sku_id,
            amount: item.quantity
          }
      end

      content = {
        to_cname: recipient.name, #收件人名称
        to_identity_card: recipient.id_card_no,
        to_identity_card_picture_path: "#{recipient.id_card_pic_obverse_url};#{recipient.id_card_pic_back_url}",
        # 正反面分号分割
        to_lu_region_id: recipient.region_id,
        to_city: LuRegion.find_by(id: recipient.region_id).name,
        to_address: recipient.address,
        to_zip_code: recipient.zip_code,
        to_mobile: recipient.tel,
        to_telephone: recipient.tel,
        to_email: recipient.email,
        sc_code: self.channel_outbound_no,

        item_list: item_list
      }.to_json    

      begin
        run_request OUTBOUND_PATH, content
      rescue Exception => e
        ExceptionNotifier.notify_exception e, env: request.env, data: { message: "通知出库失败" }                
        {}
      end
      
      # d = digest content

      # RestClient.post "#{Inbound.notify_host}/create_shopshow_outbound", {data_digest: d, content: content }
    end 


    def query_shopshow_outbound
      content = { sc_code: self.channel_outbound_no }.to_json
      response = run_request QUERY_OUTBOUND_PATH, content
      # d = digest content
      # ret = RestClient.post "#{Inbound.notify_host}/query_uszcn_outbound", {data_digest: d, content: content }    
      response
    end

    class << self

      def create_waybill_remark
        content = { 
                    agent_code: '1211200520208649',
                    state: 'SEND', 
                    remark: '就是这样' 
                  }.to_json
        response = run_request CREAT_WAYBILL_REMARK, content        
        response        
        # d = Digest::MD5.base64digest("#{content}7aa7abd59bfd34ui")
        # RestClient.post 'http://cn.uszcn.local:3000/shopshow_api/create_waybill_remark', {data_digest: d, content: content }    
      end
      
      def update_id_card
        content = {      
          sc_code: 'SC201412250001',
          to_identity_card_picture_path: 'http://ec4.images-amazon.com/images/I/31KLFx%2BNuuL.jpg'
        }.to_json

        response = run_request UPDATE_SHOPSHOW_OUTBOUND_ID_PIC, content
        response
        # d = Digest::MD5.base64digest("#{content}7aa7abd59bfd34ui")
        # RestClient.post 'http://cn.uszcn.local:3000/shopshow_api/update_shopshow_outbound_id_pic', {data_digest: d, content: content }    
      end

    end

  end 
end