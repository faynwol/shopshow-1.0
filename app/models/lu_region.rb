class LuRegion < ActiveRecord::Base  
  default_scope { order('show_order ASC') }
end
