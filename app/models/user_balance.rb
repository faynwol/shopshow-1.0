class UserBalance < ActiveRecord::Base
  self.primary_key = :user_id
    
  has_many :histories, -> { order 'created_at DESC' }, class_name: 'BalanceHistory'

  validates_numericality_of :balance

  enum status: [ :normal, :locked ]

  class Not_Enough_Balance < Exception; end
end
