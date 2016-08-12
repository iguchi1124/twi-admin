class FollowersController < ApplicationController
  def index
    @followers = current_account.rest_client.followers.attrs[:users]
  end
end
