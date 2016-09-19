class UnreturnedFriendsController < ApplicationController
  def index
    friend_ids = current_account.rest_client.friend_ids.to_a
    follower_ids = current_account.rest_client.follower_ids.to_a
    @unreturned_friend_ids = friend_ids - follower_ids
  end
end
