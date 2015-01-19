require "entities"
require "helpers"
require 'qiniu'

module Shopshow
  class API < Grape::API
    version 'v1'
    prefix :api
    default_error_formatter :json
    format :json
    content_type :json, 'application/json;charset=utf-8'

    CURRENT_CLIENT_VERSION = '1.0.9'

    rescue_from ActiveRecord::RecordNotFound  do |e|
      Rack::Response.new({ data: nil, error: e.message }.to_json, 404).finish
    end

    formatter :json, lambda { |object, env|               
      { error: '', data: object }.to_json
    }

    error_formatter :json, lambda { |message, backtrace, options, env|  
      { error: message, data: nil }.to_json        
    }    

    helpers APIHelpers

    before do
      params.each { |k, v| v.force_encoding(Encoding::UTF_8) if v.is_a?(String) } 
      Rails.logger.info params
    end

    get :version do
      force_update = version(CURRENT_CLIENT_VERSION) > version(params[:client_version])
      
      {
        force_update: force_update,
        latest: CURRENT_CLIENT_VERSION,
        download_url: 'http://fir.im/shopshow' 
      }
    end

    # 客户端登录
    post :sign_in do
      # error!('服务器正在维护中, 请稍安勿躁 ^_^', 200)

      if user = User.auth(params[:email], params[:password])
        user.ensure_private_token!
        self.current_user = user
        record_device
        present user, with: APIEntities::User, with_private_token: :yes
      else
        error!('错误的邮箱或者密码', 200)
      end
    end

    # 客户端使用 Token 登录
    post :auth_by_token do
      user = User.find_by private_token: params[:token]
      if user
        current_user = user
        record_device

        present user, with: APIEntities::User, with_private_token: :yes
      else
        error!('Token 验证失败', 200)
      end
    end

    # 七牛上传接口
    post :qiniu do
      put_policy = Qiniu::Auth::PutPolicy.new(
        'zsy-test'                    # 存储空间
      )

      uptoken = Qiniu::Auth.generate_uptoken(put_policy)
      { uptoken: uptoken } 
    end

    # 阿里云OSS上传接口
    post :sign_oss do
      authenticate!

      material = Material.prepare_for_oss!(
        current_user.id, 
        params[:live_show_id], 
        params[:extension],
        params[:meta]
      )

      digest = OpenSSL::Digest.new('sha1')
      object_key = material.resource.path

      auth_time = (DateTime.now + Rational(30, 24 * 60)).strftime("%Y-%m-%dT%H:%M:%S.000Z")

      data = { 
        expiration: auth_time, 
        conditions: [
          { bucket: 'shopshow' }, 
          ["starts-with", "$key", object_key]
        ] 
      }

      raw = Base64.strict_encode64(data.to_json)

      hmac = OpenSSL::HMAC.digest(
        digest, 
        CarrierWave::Uploader::Base.aliyun_access_key, 
        raw
      )

      hmac = Base64.strict_encode64(hmac)

      { 
        raw: raw,
        hmac: hmac,
        access_id: CarrierWave::Uploader::Base.aliyun_access_id,
        host: "http://shopshow.oss-cn-hangzhou.aliyuncs.com/",
        oss_filename: material.resource.path,
        filename: material.read_resource_attribute
      }
    end

    post :logout do 
      authenticate!
      begin
        current_user.devices.update_all(jpush_register_id: nil)
        {success: true}
      rescue => e        
        {success: false}
      end
    end

    resources :users do
      # 根据用户昵称查找某个用户
      get ':name' do
        authenticate!
        user = User.find_by name: params[:name]
        present user, with: APIEntities::User
      end

      # 修改用户头像
      post 'update_avatar' do
        authenticate!

        current_user.avatar = params[:avatar]
        current_user.save!
        present current_user, with: APIEntities::User
      end
    end

    # 收件人管理
    resources :recipients do
      # 返回地区列表
      get :regions do
        authenticate!
        regions = LuRegion.all
        present :regions, regions, with: APIEntities::LuRegion
      end

      # 当前登录用户的收件人列表
      get do
        authenticate!
        present :recipients, current_user.recipients, with: APIEntities::Recipient        
      end

      # 创建收件人
      post do
        authenticate!
        region = LuRegion.find_by name: params[:region_name]
        recipient = current_user.recipients.build
        recipient.name = params[:name]
        recipient.region_id = region.try(:id)
        recipient.address = params[:address]
        recipient.tel = params[:tel]
        recipient.email = params[:email]
        recipient.zip_code = params[:zip_code]
        recipient.id_card_no = params[:id_card_no]
        recipient.id_card_pic_obverse = params[:id_card_pic_obverse]
        recipient.id_card_pic_back = params[:id_card_pic_back]

        if recipient.save
          present recipient, with: APIEntities::Recipient
        else
          error!(recipient.errors.full_messages, 200)
        end
      end

      # 删除某个收件人
      delete ':id' do
        authenticate!
        recipient = current_user.recipients.find params[:id]
        recipient.destroy
        { recipient_id: params[:id] }
      end
    end

    # 产品管理
    resources :products do
      # 获取某个产品的信息
      get ':id' do
        authenticate!
        product = Product.find params[:id]
        present product, with: APIEntities::Product
      end     

      # 创建产品
      post do
        authenticate!
        material = Material.where(resource: params[:filename]).first
        product = current_user.products.build 
        product.description = params[:description]
        product.name_cn = params[:description]
        product.name_en = params[:name]
        product.price = params[:original_price]
        product.live_show_id = params[:live_show_id]
        product.cover_id = material.id
        product.weight = params[:weight].to_f
        product.weight_unit = params[:weight_unit]
        product.status = "published"
        product.save!
        product.materials << material

        present product, with: APIEntities::Product    
      end

      # 将商品添加到购物车
      post :add_to_cart do
        # id: 商品id
        # specification: 商品规格字符串
        # quantity: 添加到购物车的数量

        authenticate!
        product = Product.find params[:id]
        error!('直播已结束', 200) if product.live_show.shut_down?

        cart = product.add_to_cart_of(current_user, params[:specification], params[:quantity])

        { product: product, cart: cart }
      end
    end

    # 订单管理
    resources :orders do
      # 确认订单
      post do
        authenticate!
        
        live_show = LiveShow.find params[:live_show_id]
        if live_show.shut_down?
          error!('直播已结束', 200)
        end

        begin
          goods = UserGoodsInCart.where id: params[:good_ids].split(',')
          goods.destroy_all

          order = Order.create_order_with_items current_user, 
                                                params[:live_show_id], 
                                                params[:items],
                                                params[:recipient_id],
                                                params[:remark]

          recipient = Recipient.find params[:recipient_id]
          present recipient, with: APIEntities::Recipient
          present order, with: APIEntities::Order
        rescue Exception => e
          ExceptionNotifier.notify_exception e, env: request.env, 
                                                data: { message: "下单出错了" }
          error!('确认订单过程中出错了', 200)          
        end
      end

      # 从余额扣款
      post ':id/pay' do
        authenticate!

        begin
          ActiveRecord::Base.transaction do
            order = Order.find params[:id]
            error!('直播已结束', 200) if order.live_show.shut_down?
            
            balance = current_user.user_balance
            balance ||= UserBalance.create!(user_id: current_user.id)
            
            if balance.locked?
              order.failed!
              error!('该账户已被锁定，不能完成支付', 200)
            end

            if current_user.balance < order.amount
              order.failed!          
              error!('账户余额不足', 200)
            end

            order.pay!

            { order: order, balance: current_user.balance }
          end
        rescue Exception => e
          ExceptionNotifier.notify_exception e, env: request.env, 
                                                data: { message: "支付过程中出错了" }
          error!('支付过程中出错了', 200)
        end
      end

      # 取消订单
      post ':id/cancel' do
        authenticate!

        begin 
          ActiveRecord::Base.transaction do
            order = Order.find params[:id]
            if not order.cancelable?
              error!('订单现在无法被取消', 200)
            end
            order.cancel!
            { order: order, balance: current_user.balance }
          end
        rescue Exception => e
          ExceptionNotifier.notify_exception e, env: request.env, 
                                                data: { message: "取消订单出错了" }
          error!('取消订单出错了', 200)          
        end
      end
    end

    resources :live_shows do
      # 获取所有的直播室列表
      get do
        live_shows = LiveShow.order('created_at DESC')

        present :banners, LiveShow.ads
        present :live_shows, live_shows, with: APIEntities::LiveShow
      end

      # 返回某个直播活动中发布的所有产品
      # Example: /api/v1/live_shows/d16393be/products.json
      get ':id/products' do
        live_show = LiveShow.find params[:id]
        products = live_show.products.published.order('published_at DESC')

        present products, with: APIEntities::Product
      end

      get ':id/countdown' do
        begin        
          live_show = LiveShow.find params[:id]
          {
              countdown: live_show.countdown.minutes - (Time.now - live_show.close_time),
              live_show_id: live_show.id,
              live_show_name: live_show.subject
          }
        rescue => e
          {}
        end
      end

      get 'closed_shows' do
        begin
        
          l = LiveShow.where("close_time <> ''").closed.order('close_time desc').first
          raise '你妹 没设倒计时' if l.countdown.blank?
          countdown = l.countdown.minutes - (Time.now - l.close_time)
          raise '哎 倒计时结束! 你妹' if countdown <= 0 

          {
              countdown: l.countdown.minutes - (Time.now - l.close_time),
              live_show_id: l.id,
              live_show_name: l.subject
          }                                                
        rescue => e          
          {}
        end
      end
    end

    # 获取聊天历史信息
    resources :messages do
      post do              
        start, limit = params[:start].to_i, params[:limit].to_i
        if start.zero? and limit.zero?
          msgs = Message.where(live_show_id: params[:live_show_id]).order('id desc').limit(10)          
        else          
          msgs = Message.where('id <= ? and live_show_id = ?', start, params[:live_show_id]).order('id desc').limit(limit)
        end
        
        ret = msgs.map{|m|
          {
            id: m[:id],
            user_id: m[:user_id],
            nickname: User.find_by(id: m[:user_id]).name,
            body: m[:body]
          }
        }

        next_start = ret.last.present? ? (start.zero? ? (ret.last[:id].to_i - 1) : (start - limit)) : 0
        next_start = 0 if next_start < 0 
        { msgs: ret, next_start: next_start.to_s }
      end
    end

  end
end
