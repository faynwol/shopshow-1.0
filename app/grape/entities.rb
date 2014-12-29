module Shopshow
  module APIEntities
    class User < Grape::Entity
      expose :id, :name, :jid, :email, :created_at
      expose :private_token, if: { with_private_token: :yes }
      expose :ejabberd_password do |model|
        model.ejabberd_password
      end

      expose :avatar do |model|
        model.avatar_url
      end

      expose :balance do |model|
        b = model.user_balance
        b ||= UserBalance.create!(user_id: model.id)        
        b.balance
      end

      expose :recipients do |model|
        APIEntities::Recipient.represent model.recipients
      end
    end

    class LuRegion < Grape::Entity
      expose :id, :name, :pinyin
    end

    class Recipient < Grape::Entity
      expose :id, :zip_code, :name, :region_id, :address,
             :tel, :email, :id_card_no, :default

      expose :region_name do |model|
        model.lu_region.name
      end

      expose :address_full do |model|
        model.address_full
      end

      expose :id_card_pic_obverse_url do |model|
        model.id_card_pic_obverse_url
      end

      expose :id_card_pic_back_url do |model|
        model.id_card_pic_back_url
      end       
    end

    class Product < Grape::Entity
      expose :id, :live_show_id, :name_en, :name_cn, :description, 
              :price, :currency, :clearing_price, :clearing_currency,
             :tax_rate, :brand_en, :brand_cn, :carriage, :weight_str

      expose :clearing_price do |model|
        if model.clearing_price.blank?
          model.price * model.live_show.exchange_rate
        else
          model.clearing_price
        end
      end

      expose :cover_url do |model|
        model.cover.resource_url
      end

      expose :specifications do |model|
        h = {}
        begin
          # model.content[:specifications].each_pair do |k, v| 
          #   h[k] = v.split(/,|，|\s/)
          # end
          model.specifications.each do |spec|
            h[spec.name] = spec.value_as_array 
          end
        rescue => e
        end
        h
      end

      expose :materials do |model|
        APIEntities::Material.represent model.materials
      end

      expose :carriage do |model| 
        model.carriage
      end

      expose :weight_str do |model|
        "#{model.weight}#{model.weight_unit}"
      end

    end

    class Sku < Grape::Entity
      expose :sku_id, :prop, :weight
    end

    class Material < Grape::Entity
      expose :id, :material_type, :resource_url
    end

    class LiveShow < Grape::Entity
      expose :id, :subject, :description, :status, 
             :start_time, :close_time, :closed,
             :exchange_rate, :countdown, :html_url

      expose :preview_url do |model|
        model.preview_url
      end

      expose :host_ids do |model|
        model.host_ids
      end

      expose :room_jid do |model|
        model.room_jid
      end
    end

    class Order < Grape::Entity
      expose :id, :amount, :original_amount, :status
      expose :can_be_cancel do |model|
        model.cancelable?
      end
    end

    class OrderItem < Grape::Entity
      expose :product_id, :sku_id, :quantity
    end
  end
end