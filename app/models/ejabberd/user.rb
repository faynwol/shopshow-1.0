class Ejabberd::User < Ejabberd::Base
  validates_uniqueness_of :username, on: :create
end