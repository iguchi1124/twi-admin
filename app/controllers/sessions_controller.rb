class SessionsController < ApplicationController
  def create
    account = Account.upsert_by_omniauth_params(request.env['omniauth.auth'])
    session[:account_id] = account.id

    redirect_to root_path, notice: 'Successfully signed in.'
  end

  def destroy
    session.delete(:account_id)
  end
end
