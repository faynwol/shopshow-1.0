require 'permanent_records'

class MobileVerifyCode < Token
  validates_presence_of :phone, on: :create

  ACTIVE_TIME = 1.minutes

  before_create do
    self.body = g_code
  end

  def is_valid?
    Time.now - created_at <= ACTIVE_TIME     
  end

  private

  def g_code
    rand(9999).to_s.rjust(4, '0')
  end
end