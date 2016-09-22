class FriendsController < ApplicationController
  def index
    @friends = current_account.friends
  end
end
