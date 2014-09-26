class Admin::AdminsController < ApplicationController

  before_filter :authorize

  def show
    @admin = Admin.first
  end

  def new
    @admin = Admin.new
  end

  def create
    @admin = Admin.new(admin_params)

    if @admin.save
      redirect_to admin_path
    else
      render 'new'
    end
  end

  private
    def admin_params
      params.require(:admin).permit(:name, :avatar, :password, :password_confirmation)
    end
end
