module Delivery
  module ApplicationHelper
    def format_message(message)
      case message.celltype
      when "UserText", "AdminText"
        content_tag "div", class: 'text-muted' do
          message.content
        end
      when "AdminImage"
        img = image_tag message.image_url
        "<p class='mt-10'>#{img}</p>".html_safe
      when "Product"
        %Q(
          <div class="panel panel-default">
            <div class="panel-heading">
              <a href="#{edit_delivery_product_path(message.product, live_show_id: message.live_show_id)}">#{message.product.name_en}</a>
            </div>
            <div class="panel-body">
              <img src="#{message.product.cover.resource_url}">
            </div>
          </div>
        ).html_safe
      end
    end
  end
end