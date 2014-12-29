class Inbound < ActiveRecord::Base
  include UszcnUtils::Inbound
  include ReadableStatus

  has_many :orders, through: :inbound_orders
  has_and_belongs_to_many :skus, join_table: :inbound_skus
  has_many :inbound_skus
  has_many :outbounds
  belongs_to :channel
  belongs_to :live_show

  validates_presence_of :status
  validates_uniqueness_of :channel_inbound_no

  enum status: [
    :pending, #处理中
    :finish,  #处理完成
    :failed   # 通知入库失败
  ]

  before_create :g_channel_inbound_no
  def g_channel_inbound_no
    self.channel_inbound_no = UszcnUtils.g_inbound_no!
  end

  def notify_channel_inbound
    case channel.name
    when "USZCN"
      uszcn_notify_inbound
    end      
  end

  def query_channel_inbound!
    case channel.name
    when "USZCN"
      uszcn_query_inbound!
    end      
  end
end


































