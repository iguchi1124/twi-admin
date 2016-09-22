class FriendsController < ApplicationController
  def index
    @friends = current_account.friends
  end

  def create
    current_account.follow!(params[:id])
    redirect_to :back, notice: 'follow!'
  end

  def destroy
    current_account.unfollow!(params[:id])
    redirect_to :back, notice: 'remove!'
  end
end
