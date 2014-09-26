class Admin::DashboardController < ApplicationController

  before_filter :authorize

  def index
    @admin = current_user
    @farmers = User.where('role = ?', '1')
    @buyers =  User.where('role = ?', '2')
    @users = User.order('created_at DESC')
  end

  def message
    recepients = params[:to]
    message = params[:sendout]

    if message.present?
      recepients.split(',').each do |phone|
        KannelRails.send_message(phone, message)
      end
      flash[:alert] = "Sent Messages to users"
      redirect_to admin_message_path
    end
  end
end
