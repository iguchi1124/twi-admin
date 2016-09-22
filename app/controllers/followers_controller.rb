class FollowersController < ApplicationController
  def index
    @followers = current_account.followers
  end
end
