class User < ActiveRecord::Base
  include PrimaryKeySecurity
  
  has_secure_password
  
  validates_uniqueness_of :phone
  validates :username, uniqueness: { case_sensitive: false }, allow_blank: true
  validates :name, uniqueness: { case_sensitive: false }, presence: true, length: { maximum: 20, minimum: 2 }
  validates :email, uniqueness: { case_sensitive: false }, allow_blank: true, format: { with: /\A([^@\s]+)@((?:[a-z0-9-]+\.)+[a-z]{2,})\z/i }

  has_many :live_shows
  has_many :products, foreign_key: 'author_id'
  has_many :goods_in_cart, class_name: 'UserGoodsInCart', foreign_key: 'user_id'
  has_many :materials
  has_many :orders
  has_many :devices, class_name: 'UserDevice', foreign_key: 'user_id'
  has_one :user_balance
  has_many :recipients
  has_many :mobile_verify_codes

  delegate :balance, to: :user_balance, allow_nil: true

  mount_uploader :avatar, AvatarUploader

  def self.auth(login, password)
    if login.include?("@")
      user = User.find_by(email: login)
    else
      user = User.find_by(phone: login) || User.find_by(name: login)
    end
    
    if user && user.authenticate(password)
      user
    else
      nil
    end
  end

  def self.admin
    User.find_by(email: 'jimmy.huangjin@gmail.com') || User.first
  end

  after_create :sync_ejabberd_user
  def sync_ejabberd_user
    e_user = Ejabberd::User.new
    e_user.username = self.name
    e_user.password = self.password
    e_user.created_at = self.created_at
    e_user.save!
  end

  def remember_token
    [id, Digest::SHA512.hexdigest(password_digest)].join('$')
  end

  def self.find_by_remember_token(token)
    user = find_by_id(token.split('$').first)
    (user && Rack::Utils.secure_compare(user.remember_token, token)) ? user : nil
  end

  def admin?
    Settings.admin_emails.include? email
  end

  # 重新生成 Private Token
  def update_private_token
    random_key = "#{SecureRandom.hex(10)}_#{self.id}"
    self.update_attribute(:private_token, random_key)
  end

  def ensure_private_token!
    self.update_private_token if self.private_token.blank?
  end

  def jid
    "#{name}@#{Settings.jabber_server}"
  end

  def jid_bind(resource)
    "#{jid}/#{resource}"
  end

  def ejabberd_password
    e_user = Ejabberd::User.find_by(username: name)
    e_user.password
  end

  def default_recipient
    recipients.first
  end
  
end
