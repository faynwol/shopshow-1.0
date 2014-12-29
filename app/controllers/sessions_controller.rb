class SessionsController < ApplicationController
  before_action :no_login_required, only: [:new, :create]

  def new
    store_location params[:return_to]
  end

  def create
    @user = User.where(email: params[:email].downcase).first

    if @user && @user.authenticate(params[:password])
      login_as @user
      remember_me
      redirect_back_or_default root_url
    else
      flash[:warning] = t('sessions.flashes.incorrect_email_or_password')
      redirect_to login_url
    end
  end

  def destroy
    logout
    redirect_to root_url
  end
end