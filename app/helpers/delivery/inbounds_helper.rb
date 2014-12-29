module Delivery
  module InboundsHelper
    def flag_tag(inbound)
      klass = "label label-"
      case inbound.status
      when "pending"
        klass << "default"
      when "finish"
        klass << "success"
      else
        klass << "danger"
      end

      content_tag 'span', class: klass do
        inbound.status.upcase
      end
    end
  end
end