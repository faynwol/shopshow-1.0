class Material < ActiveRecord::Base
  include PrimaryKeySecurity

  mount_uploader :resource, ResourceUploader

  belongs_to :user
  belongs_to :live_show
  has_and_belongs_to_many :products, join_table: :product_materials

  attr_accessor :is_thumbnable

  def self.prepare_for_oss!(user_id, live_show_id, extension, meta = {})
    skip_callback :save, :after, :store_resource!
    md5_filename = Digest::MD5.hexdigest("#{extension}-#{Time.now.to_i}-#{SecureRandom.hex(2)}")
    material = new
    material.live_show_id = live_show_id
    material.generate_secure_id!
    material.user_id = user_id
    material.material_type = extension.downcase
    material.instance_eval do
      write_attribute :resource, "#{md5_filename}.#{extension.downcase}"
    end
    material.save!
    set_callback :save, :after, :store_resource!
    material
  end

  def read_resource_attribute
    read_attribute :resource
  end
end
