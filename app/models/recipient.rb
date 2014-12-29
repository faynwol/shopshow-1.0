class Recipient < ActiveRecord::Base
  belongs_to :user
  belongs_to :lu_region, foreign_key: :region_id
  has_many :orders
  
  validates_presence_of :name, :region_id, :address, :tel, 
                        :email, :id_card_no, :id_card_pic_obverse, :id_card_pic_back

  mount_uploader :id_card_pic_obverse, IdCardPicUploader
  mount_uploader :id_card_pic_back, IdCardPicUploader

  # def address
  #   addr = read_attribute(:address)
  #   if not addr.include?(lu_region.name)
  #     addr = lu_region.name + addr
  #   end
  #   addr
  # end

  def address_full
    addr = address
    if not addr.include?(lu_region.name)
      addr = lu_region.name + addr
    end
    addr
  end
end