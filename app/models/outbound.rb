class Outbound < ActiveRecord::Base
  include UszcnUtils::Outbound 

  belongs_to :inbound
  belongs_to :order

  before_create :g_channel_outbound_no
  def g_channel_outbound_no
    self.channel_outbound_no = UszcnUtils.g_outbound_no!
  end  

  def notify_tax
    client = JPush::JPushClient.new(Settings.app_key, Settings.master_secret);    
    registration_id = self.order.user.devices.where("jpush_register_id <> ''").map(&:jpush_register_id)
    return if registration_id.blank?   
    payload = JPush::PushPayload.build(
     platform: JPush::Platform.all,
     audience: JPush::Audience.build(registration_id: registration_id),
     notification: JPush::Notification.build(
        alert: nil,
        ios: JPush::IOSNotification.build(
          alert: "您的订单编号为#{self.id}的订单需要缴纳关税#{self.tax.to_f}元,请尽快缴费!",          
          badge: 0,
          sound: "happy"

        )
      )
    )
    client.sendPush(payload)     	
  end

end
