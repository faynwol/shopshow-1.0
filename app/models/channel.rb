class Channel < ActiveRecord::Base
  validates_presence_of :status
	has_many :inbounds

	def self.default
		Channel.first
	end
end
