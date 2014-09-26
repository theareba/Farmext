class Admin::UsersController < ApplicationController

  before_filter :authorize

  def index
    @users = User.all
    @admin = current_user
  end

  def farmers
    @admin = current_user
    @users = User.where('role = ?', '1')
  end

  def buyers
    @admin = current_user
    @users = User.where('role = ?', '2')
  end

end
