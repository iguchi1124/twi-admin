class SessionsController < ApplicationController
  def create
    user = User.upsert_by_omniauth_params!(request.env['omniauth.auth'])
    session[:user_id] = user.id

    redirect_to root_path, notice: 'Successfully signed in.'
  end

  def destroy
    session.delete(:user_id)
    redirect_to root_path, notice: 'Successfully signed out.'
  end
end
