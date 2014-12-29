class InboundOrder < ActiveRecord::Base
  belongs_to :inbound
  belongs_to :order

  validates_presence_of :inbound_id, :order_id

end
