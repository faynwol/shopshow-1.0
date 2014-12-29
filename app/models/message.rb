require 'nokogiri'

class Message < ActiveRecord::Base
  include PrimaryKeySecurity

  belongs_to :user
  belongs_to :to_user, class_name: 'User', foreign_key: 'to_user_id'
  belongs_to :live_show

  default_scope {
    where(chat_type: 'groupchat')
  }

  def body_as_str
    @body_as_str ||= Nokogiri.HTML(body || '')
  end

  def celltype
    body_as_str.xpath("//celltype").first.try(:content)
  end

  def content
    body_as_str.xpath("//content").first.try(:content)
  end

  def image_url
    host = "http://shopshow.oss-cn-hangzhou.aliyuncs.com"
    path = body_as_str.xpath("//imageid").first.try(:content)
    File.join host, path
  end

  def product
    p 22222222
    product_id = body_as_str.xpath("//productid").first.try(:content)
    Product.find_by id: product_id
  end

  class << self
    def g_product_cell(product)
      cell = g_base_cell 'Product', product.author_id, product.live_show_id
      cell << "<ProductID>#{product.id}</ProductID>"
      p cell
      cell
    end

    private

    def g_base_cell(cell_type, user_id, live_show_id)
      "<CellType>#{cell_type}</CellType><UserID>#{user_id}</UserID><LiveShowID>#{live_show_id}</LiveShowID>"
    end
  end
end
