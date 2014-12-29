module PrimaryKeySecurity
  extend ActiveSupport::Concern

  included do
    self.primary_key = "id"

    validates_uniqueness_of :id, on: :create

    before_validation { 
      if self.new_record? && self.id.blank?
        self.id = SecureRandom.hex(4)
      end
    }
  end

  def generate_secure_id!
    if self.id.present?
      raise 'Secure random hex id generated already!'
    else
      self.id = SecureRandom.hex(4)
    end
  end

  module ClassMethods; end
end