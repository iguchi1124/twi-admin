class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  helper_method :current_account, :signed_in?

  def current_account
    if session[:account_id].present?
      @current_account ||= Account.find(session[:account_id])
    end
  end

  def signed_in?
    @current_account.present?
  end
end
