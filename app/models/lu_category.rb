class LuCategory < ActiveRecord::Base
  scope :active, -> {
    where(parent_id: 0, state: 'ACTIVE')
  }

  def children
    LuCategory.where(parent_id: self.parent_id, state: 'ACTIVE')
  end
end