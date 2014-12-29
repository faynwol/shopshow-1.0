class Token < ActiveRecord::Base
  default_scope { where(:deleted_at => nil) }

  belongs_to :user

  validates_uniqueness_of :body, on: :create, scope: [ :type, :status ]

  # enum status: [
  #   :is_valid, # Because AR have a #valid method alreay
  #   :is_invalid
  # ]

  def self.deleted
    self.unscoped.where('deleted_at is NOT null')
  end

  def active!
    destroy!
  end
end