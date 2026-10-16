# frozen_string_literal: true
class PasswordResetsController < ApplicationController
  skip_before_action :authenticated

  def reset_password
    user = nil
    if !params[:token].nil? && is_valid?(params[:token])
      user = @user
    end

    if user && params[:password] && params[:confirm_password] && params[:password] == params[:confirm_password]
      user.password = params[:password]
      user.save!
      flash[:success] = "Your password has been reset please login"
      redirect_to :login
    else
      flash[:error] = "Error resetting your password. Please try again."
      redirect_to :login
    end
  end

  def confirm_token
    if !params[:token].nil? && is_valid?(params[:token])
      flash[:success] = "Password reset token confirmed! Please create a new password."
      render "password_resets/reset_password"
    else
      flash[:error] = "Invalid password reset token. Please try again."
      redirect_to :login
    end
  end

  def send_forgot_password
    @user = User.find_by_email(params[:email]) unless params[:email].nil?

    if @user && password_reset_mailer(@user)
      flash[:success] = "Password reset email sent to #{params[:email]}"
      redirect_to :login
    else
      flash[:error] = "There was an issue sending password reset email to #{params[:email]}".html_safe unless params[:email].nil?
    end
  end

  private

  def password_reset_mailer(user)
    token = generate_token(user.id, user.email)
    UserMailer.forgot_password(user.email, token).deliver
  end

  def generate_token(id, email)
    hmac = OpenSSL::HMAC.hexdigest('SHA256', Rails.application.secret_key_base, "#{id}:#{email}")
    "#{id}-#{hmac}"
  end

  def is_valid?(token)
    if token =~ /\A(?<user_id>\d+)-(?<token_hmac>[0-9a-f]{64})\z/i
      # Fetch the user by their id
      @user = User.find_by(id: $~[:user_id])
      return false unless @user

      # Recompute the HMAC and compare in constant time
      expected = OpenSSL::HMAC.hexdigest('SHA256', Rails.application.secret_key_base, "#{@user.id}:#{@user.email}")
      ActiveSupport::SecurityUtils.secure_compare(expected, $~[:token_hmac])
    end
  end
end
