module Delivery
  module ProductsHelper
    def status_tag product
      klass = "label"

      case product.status
      when "draft", "locked"
        klass << " label-default"
      when "previewing"
        klass << " label-info"
      when "published"
        klass << " label-success"
      end
          
      %Q(<span class="#{klass}">#{product.readable_status}</span>).html_safe
    end
  end
end