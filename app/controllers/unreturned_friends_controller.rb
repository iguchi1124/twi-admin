class UnreturnedFriendsController < ApplicationController
  def index
    @unreturned_friends = current_user.unreturned_friends
  end
end
