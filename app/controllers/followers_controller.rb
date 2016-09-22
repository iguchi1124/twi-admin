class FollowersController < ApplicationController
  def index
    follower_ids = current_account.rest_client.follower_ids.to_a
    @followers = current_account.rest_client.users(follower_ids)
  end
end
