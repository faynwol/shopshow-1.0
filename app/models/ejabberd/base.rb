class Ejabberd::Base < ActiveRecord::Base
  self.abstract_class = true
  establish_connection Settings.ejabberd_database
end