module ReadableStatus
  extend ActiveSupport::Concern

  module ClassMethods
    def statuses_i18n
      I18n.t("statuses.#{self.to_s.downcase}").stringify_keys
    end    
  end

  def readable_status
    self.class.statuses_i18n[self.status]
  end
end