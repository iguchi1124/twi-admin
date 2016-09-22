class FriendsController < ApplicationController
  def index
    @friends = current_user.friends
  end

  def create
    current_user.follow!(params[:id])
    redirect_to :back, notice: 'follow!'
  end

  def destroy
    current_user.unfollow!(params[:id])
    redirect_to :back, notice: 'remove!'
  end
end
