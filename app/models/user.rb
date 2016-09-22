class User < ApplicationRecord
  validates :provider, inclusion: { in: ['twitter'] }

  def follower_ids
    @follower_ids ||= Rails.cache.fetch(cache_key(:follower_ids)) do
      rest_client.follower_ids.to_a
    end
  end

  def followers
    @followers ||= Rails.cache.fetch(cache_key(:followers)) do
      users(follower_ids)
    end
  end

  def friend_ids
    @friend_ids ||= Rails.cache.fetch(cache_key(:friend_ids)) do
      rest_client.friend_ids.to_a
    end
  end

  def friends
    @friends ||= Rails.cache.fetch(cache_key(:friends)) do
      users(friend_ids)
    end
  end

  def unreturned_friends
    @unreturned_friends ||= Rails.cache.fetch(cache_key(:unreturned_friends)) do
      users(friend_ids - follower_ids)
    end
  end

  def follow!(*user_ids)
    users_to_follow = users(user_ids.flatten)
    rest_client.follow(users_to_follow)
    refresh_cached_friends(friends + users_to_follow)
  end

  def unfollow!(*user_ids)
    users_to_unfollow = users(user_ids.flatten)
    rest_client.unfollow(users_to_unfollow)
    refresh_cached_friends(friends - users_to_unfollow)
  end

  def followed?(user)
    friends.include?(user)
  end

  def self.upsert_by_omniauth_params!(params)
    user = find_or_initialize_by(provider: params['provider'], uid: params['uid'])
    user.provider = params['provider']
    user.uid = params['uid']
    user.nickname = params['info']['nickname']
    user.name = params['info']['name']
    user.email = params['info']['email']
    user.image_url = params['info']['image']
    user.description = params['info']['description']
    user.access_token = params['credentials']['token']
    user.access_token_secret = params['credentials']['secret']
    user.save!

    user
  end

  private

  def rest_client
    @rest_client ||= Twitter::REST::Client.new(oauth_params)
  end

  def streaming_client
    @streaming_client ||= Twitter::Streaming::Client.new(oauth_params)
  end

  def oauth_params
    Rails.application.secrets.twitter.merge(attributes.slice('access_token', 'access_token_secret'))
  end

  def cache_key(attr)
    "#{self.id}_#{attr}"
  end

  def user_cache_key(id)
    "user_#{id}"
  end

  def users(*user_ids)
    user_ids = user_ids.flatten
    users = user_ids.map { |id| Rails.cache.read(user_cache_key(id)) }
    ids_users = Hash[user_ids.zip(users)]

    unfilled_ids = ids_users.select { |_, v| v.nil? }.keys
    rest_client.users(unfilled_ids).each do |user|
      ids_users[user.id] = Rails.cache.fetch(user_cache_key(user.id)) { user }
    end

    ids_users.values
  end

  def refresh_cached_friends(friends)
    Rails.cache.write(cache_key(:friend_ids), friends.map(&:id))
    Rails.cache.write(cache_key(:friends), friends)
  end

  def refresh_cached_followers(followers)
    Rails.cache.write(cache_key(:follower_ids), followers.map(&:id))
    Rails.cache.write(cache_key(:followers), followers)
  end
end
