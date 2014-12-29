class ProductSpecification < ActiveRecord::Base
  default_scope { where(parent_id: 0) }

  belongs_to :product

  validates_presence_of :name, :value
  validates_uniqueness_of :name, on: :create, scope: :product_id

  # def values_str=(new_values_str)
  #   if values_str != new_values_str
  #     attribute_will_change!('values_str') 
  #   end
  #   @values_str = new_values_str.split(/,|，/).join(",")
  # end

  # def values_str
  #   @values_str || self.values.map(&:name).join(",")
  # end

  # def values_str_changed?
  #   changed.include?('values_str')
  # end

  # def values
  #   self.class.unscoped.where(parent_id: id)
  # end

  def value=(new_value)
    new_value = (new_value || "").split(/,|，|\s|;\|/).join(",")
    write_attribute :value, new_value
    new_value
  end

  def value_as_array
    (value || "").split ","
  end
end
