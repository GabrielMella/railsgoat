# frozen_string_literal: true
class WorkInfoController < ApplicationController
  def index
    @user = User.find_by(id: params[:user_id])
    if !(@user) || @user.admin
      flash[:error] = "Sorry, no user with that user id exists"
      redirect_to home_dashboard_index_path
    elsif current_user.id != @user.id && !current_user.admin
      flash[:error] = "Sorry, you are not authorized to view that page"
      redirect_to home_dashboard_index_path
    end
  end

end
