class SessionsController < ApplicationController
  def new
  end

  def create
    admin = Admin.find_by_email(params[:email])
    if admin && admin.authenticate(params[:password])
      session[:admin_id] = admin.id
      redirect_to admin_path, notice: 'Logged in!'
    else
      render 'new'
      flash[:alert] = 'Email or password is invalid'
    end
  end

  def destroy
    session[:admin_id] = nil
    redirect_to root_url, notice: 'Logged out!'
  end
end

