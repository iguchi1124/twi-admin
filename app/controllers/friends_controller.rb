class FriendsController < ApplicationController
  def index
    @friends = current_user.friends
  end

  def create
    current_user.follow!(params[:id])
    redirect_to :back, notice: t('followed_an_user')
  end

  def destroy
    current_user.unfollow!(params[:id])
    redirect_to :back, notice: t('removed_an_user')
  end
end
