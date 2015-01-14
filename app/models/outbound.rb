class Outbound < ActiveRecord::Base
  include UszcnUtils::Outbound 

  belongs_to :inbound
  belongs_to :order

  before_create :g_channel_outbound_no

  OUTBOUND_STATE = {
    :init => '新建',
    :packaging_finished => '打包完成',
    :packaging_exception => '打包异常',
    :ready_for_bag => '准备装邮袋',
    :in_bag => '装进邮袋',
    :departed => '飞往中国',
    :arrived => '到达中国',
    :customs_clearance => '清关中',
    :customs_clearance_failed => '清关异常',
    :express_sent => '发送国内快递'
  }


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

  #TODO
  def self.format_outbound_state item_list
    return '此订单库房还未操作' if item_list.blank?
    s = ["当前订单共打了#{item_list.size}个包裹"]
    item_list.each do |i|
      s << "国内快递单号:" + i['express_tracking_number'] if !i['express_tracking_number'].blank?
      s << OUTBOUND_STATE[ i['state'].downcase.to_sym ]
    end
    s.join('</br>')
  end

end
