class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  helper_method :current_user, :signed_in?

  def current_user
    if session[:user_id].present?
      @current_user ||= User.find(session[:user_id])
    end
  end

  def signed_in?
    current_user.present?
  end
end
