require 'xmpp4r'
require 'xmpp4r/muc/helper/simplemucclient'

class Product < ActiveRecord::Base
  include PrimaryKeySecurity
  include Jabber
  include ReadableStatus

  has_and_belongs_to_many :materials, join_table: :product_materials
  has_many :product_materials
  belongs_to :live_show
  belongs_to :author, class_name: 'User', foreign_key: 'author_id'
  has_many :skus
  has_many :specifications, class_name: "ProductSpecification", foreign_key: 'product_id'

  accepts_nested_attributes_for :specifications, reject_if: :reject_specifications, allow_destroy: true
  def reject_specifications attributed
    attributed['name'].blank? or attributed['value'].blank?
  end

  validates_length_of :description, maximum: 100, allow_blank: true 
  validates_presence_of :name_en, :price, :currency, :weight, :weight_unit
  validates_numericality_of :price, greater_than: 0
  validates_inclusion_of :currency, in: %w( Dollar RMB )
  validates_inclusion_of :weight_unit, in: %w( kg lb oz )

  enum status: [ :draft, :previewing, :published, :locked ]

  scope :published, -> { where(status: Product.statuses[:published]) }

  attr_accessor :props

  # store :content, accessors: [:specifications]
  store :content

  CURRENCIES = %w( Dollar RMB )
  WEIGHT_UNITS = %w( kg lb oz )

  def picture_ids
    @picture_ids || self.product_materials.order('created_at desc').map(&:material_id).join(",")
  end

  def picture_ids=(new_ids)
    @picture_ids = new_ids
  end

  # !!!!临时方法
  before_validation do
    if self.author_id.blank?
      self.author_id = User.first.id
    end
  end

  before_save do
    self.clearing_price = (price.to_f * live_show.exchange_rate.to_f).ceil
    self.clearing_currency = 'RMB'
    if self.name_cn.blank?
      self.name_cn = self.description
    end
  end

  def cover
    Material.find_by id: cover_id
  end

  # 可能有问题，待测试
  def default_sku
    skus.each do |sku|
      return sku if sku.prop.blank?        
    end

    skus.create!
  end

  # 这里有点乱
  def find_or_create_sku_by!(specification_str)
    specification = {}

    # 这是新增的产品规格表
    h = {}
    specifications.each do |spec|
      h[spec.name] = spec.value
    end

    specification_str.force_encoding(Encoding::UTF_8).split(/,|，/).each do |v|
      (content["specifications"] || h).each_pair do |s_name, s_value|
        if s_value.split(/,|，/).include?(v)
          specification[s_name] = v
        end
      end
    end
  
    skus.each do |sku|
      if sku.prop.stringify_keys == specification.stringify_keys
        return sku
      end
    end

    if specification.blank?
      return default_sku
    end
    
    sku = skus.build 
    sku.prop = specification
    sku.save!
    return sku
  end

  def add_to_cart_of(user, specification_str, quantity)
    sku = find_or_create_sku_by! specification_str
    sku.add_to_cart_of user, quantity
  end

  # def publish!
  #   body = ActiveRecord::Base::Message.g_product_cell self
  #   jid = author.jid_bind('web')    
  #   Jabber::debug = true
  #   client = Jabber::Reliable::Connection.new(jid, max_retry: 10, retry_sleep: 1)
  #   muc = Jabber::MUC::MUCClient.new(client)
  #   client.connect
  #   client.auth(author.ejabberd_password)
  #   muc.join("#{live_show.room_jid}/#{author.name}")
  #   msg = Jabber::Message.new live_show.room_jid, body
  #   muc.send msg
  #   self.update_attribute(:published_at, Time.now)              
  # end

  def publish!
    body = ::Message.g_product_cell self
    message = Jabber::Message.new live_show.room_jid, body
    message.set_type(:groupchat)
    mid = Array(0..99).sample + Random.rand(9999999)
    message.set_id mid
    p live_show.client
    live_show.client.send message
  end

  def carriage
    w = self.weight.to_f
    case self.weight_unit
    when 'oz'
      w = (w * 28.34952313).ceil
    when 'lb'
      w = (w * 453.59237).ceil
    when 'kg'
      w = (w * 1000).ceil
    end     

    if w == 0
      "无法估算此产品运费"
    elsif w < 500
      "30元"
    elsif w % 100 > 0
      "#{(w / 100.0).ceil * 6}元"
    else
      "#{w / 100.0 * 6}元"
    end
  end
end
