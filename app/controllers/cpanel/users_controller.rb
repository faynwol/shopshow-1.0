class Cpanel::UsersController < Cpanel::ApplicationController
  def index
    @users = User.all
  end
end