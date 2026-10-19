# frozen_string_literal: true
class SessionsController < ApplicationController
  skip_before_action :has_info
  skip_before_action :authenticated, only: [:new, :create]

  def new
    @url = params[:url]
    redirect_to home_dashboard_index_path if current_user
  end

  def create
    path = safe_redirect_url
    begin
      # Normalize the email address, why not
      user = User.authenticate(params[:email].to_s.strip.downcase, params[:password])
    rescue RuntimeError => e
      # don't do ANYTHING
    end

    if user
      if params[:remember_me]
        cookies.permanent[:auth_token] = user.auth_token
      else
        session[:user_id] = user.id
      end
      redirect_to path
    else
      flash[:error] = e.message
      render "sessions/new"
    end
  end

  def destroy
    cookies.delete(:auth_token)
    reset_session
    redirect_to root_path
  end

  private

  def safe_redirect_url
    url = params[:url].to_s
    # Reject blank, protocol-relative (//host), and any value not starting with '/'
    return home_dashboard_index_path unless url.start_with?('/') && !url.start_with?('//')
    uri = URI.parse(url)
    (uri.relative? && uri.host.nil?) ? url : home_dashboard_index_path
  rescue URI::InvalidURIError
    home_dashboard_index_path
  end
end
