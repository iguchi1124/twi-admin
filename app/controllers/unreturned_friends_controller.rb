class UnreturnedFriendsController < ApplicationController
  def index
    @unreturned_friends = current_account.unreturned_friends
  end
end
