require 'xmpp4r'
require 'xmpp4r/muc'

class LiveShow < ActiveRecord::Base
  include PrimaryKeySecurity
  include ReadableStatus

  validates_presence_of :subject, :start_time, :html_url

  has_many :products
  has_many :materials
  has_many :orders
  has_many :order_items
  has_many :faqs
  has_many :messages
  has_many :goods_in_cart, class_name: 'UserGoodsInCart', foreign_key: 'user_id'
  belongs_to :user
  has_many :inbounds
  
  mount_uploader :preview, PreviewUploader
  
  attr_accessor :is_thumbnable

  enum status: [ :pending, :previewing, :onair, :closed ]

  CONFERENCE_HOST = 'im.shopshow.com'

  def room_jid
    "#{id}@#{CONFERENCE_HOST}"
  end

  #直播开始前30分钟发送通知
  # after_create do    
  #   push_at = self.start_time - 30.minutes
  #   LiveShow.delay(run_at: push_at, queue: self.id + '-start').jpush_notify(alert: "#{self.subject}直播间还有半小时就要开始了")
  # end

  # after_update do       
  #   a = self.start_time_change
  #   unless a.blank? 
  #     begin
  #       Delayed::Backend::ActiveRecord::Job.find_by_queue("#{self.id}-start").destroy
  #     rescue
  #       nil
  #     ensure
  #       LiveShow.delay(run_at: a[1] - 30.minutes, queue: self.id + '-start').jpush_notify(alert: "#{self.subject}直播间还有半小时就要开始了")
  #     end
  #   end
  # end

  # after_create :create_muc_room
  # def create_muc_room
  #   Jabber::debug = true

  #   client = Jabber::Reliable::Connection.new(user.jid_bind('web'), max_retry: 10, retry_sleep: 1)
  #   muc = Jabber::MUC::MUCClient.new(client)
  #   client.connect
  #   client.auth(user.ejabberd_password)
  #   muc.join("#{room_jid}/#{user.name}")
  #   muc.configure(
  #     'muc#roomconfig_roomname'       => self.subject,
  #     'muc#roomconfig_persistentroom' => 1
  #   )
  # end

  after_create do
    client.configure(
      'muc#roomconfig_roomname'       => self.subject,
      'muc#roomconfig_persistentroom' => 1
    )
  end

  def connection    
    @connection ||= Jabber::Reliable::Connection.new(user.jid_bind('web'), max_retry: 10, retry_sleep: 1)
    if not @connection.is_connected?
      @connection.connect
      @connection.auth user.ejabberd_password
    end
    @connection
  end

  def client
    Jabber::debug = true
    @client ||= Jabber::MUC::MUCClient.new(connection)
    if not @client.active?
      @client.join "#{room_jid}/#{user.name}"
    end
    @client
  end

  def host_ids
    (read_attribute(:host_ids) || '').split ','
  end

  before_create do
    add_host self.user_id
  end

  def add_host(user_id)
    ids = host_ids.push user_id
    self.host_ids = ids.join ','
  end

  #合并此直播室内所有入库单商品
  def merge_inbounds
    ret = {}
    self.inbounds.each do |ib|
      ibs = ib.inbound_skus
      ibs.each do |is|
        ret[is.sku_id] ||= {}
        ret[is.sku_id][:quantity] ||= 0
        ret[is.sku_id][:inbounded_quantity] ||= 0 
        ret[is.sku_id][:quantity] += is.quantity
        ret[is.sku_id][:inbounded_quantity] += is.inbounded_quantity
      end
    end
    ret
  end

  def self.jpush_notify opts = {}
    client = JPush::JPushClient.new(Settings.app_key, Settings.master_secret);
    registration_id = opts[:registration_id] 

    return if registration_id.blank?
    
    payload = JPush::PushPayload.build(
     platform: JPush::Platform.all,
     audience: registration_id.blank? ? JPush::Audience.all : JPush::Audience.build(registration_id: registration_id),
     notification: JPush::Notification.build(
        alert: nil,
        ios: JPush::IOSNotification.build(
          alert: opts[:alert],          
          badge: 0,
          sound: "happy"
        )
      )
    )
    client.sendPush(payload)
  end

  def jpush_notify_room_closed
    client = JPush::JPushClient.new(Settings.app_key, Settings.master_secret);    
    registration_id = User.find_by(email: 'a@a.com').devices.where("jpush_register_id <> ''").map(&:jpush_register_id)    
    return if registration_id.blank?
    payload = JPush::PushPayload.build(
     platform: JPush::Platform.all,
     audience: registration_id.blank? ? JPush::Audience.all : JPush::Audience.build(registration_id: registration_id),
     notification: JPush::Notification.build(
        alert: "专场将在#{self.countdown}分钟后关闭,请尽快下单支付",
        ios: JPush::IOSNotification.build(
          alert: "专场将在#{self.countdown}分钟后关闭,请尽快下单支付",          
          badge: 0,
          extras: {                      
            countdown: self.countdown.minutes - (Time.now - self.close_time),            
            live_show_id: self.id,
            live_show_name: self.subject
          }

        )
      )
    )
    client.sendPush(payload)    
  end

  def shut_down?
    self.closed? && (self.close_time + self.countdown.to_i.minutes) < Time.now    
  end

  def self.ads
    [
      {
        picture: 'http://shopshow.oss-cn-hangzhou.aliyuncs.com/uploads/beta_test_user/id_card_pic_front/5/19e122a4a78ce5a02c49da468d4d58af.png',
        url: 'https://jinshuju.net/f/KiER5L',
        name: '意见反馈'
      },

      {
        picture: 'http://shopshow.oss-cn-hangzhou.aliyuncs.com/uploads/beta_test_user/id_card_pic_back/5/0b0b624add1c93ed2e78497bac59b986.png',
        url: 'http://115.29.167.37/cpanel/faqs/1',
        name: '常见问题'        
      }
    ] 
  end

  def self.reset_test_data
    Inbound.destroy_all
    Outbound.destroy_all
    Order.update_all(status: 'cancel')

    Order.first(3).each do |o|
      o.update_attribute(:status, 'paid')
    end    
    InboundSku.destroy_all    
  end

end
