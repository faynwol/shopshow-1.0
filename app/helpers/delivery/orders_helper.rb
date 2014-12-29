module Delivery
  module OrdersHelper
    def order_flag_tag order
      klass = "btn btn-xs btn-"
      case order.status
      when "paid"
        klass << "success"
      when "failed"
        klass << "danger"
      else
        klass << "default"
      end

      content_tag 'a', class: klass do
        order.status.upcase
      end      
    end
  end
end