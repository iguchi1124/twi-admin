class Account < ApplicationRecord
  validates :provider, inclusion: { in: ['twitter'] }

  def follower_ids
    @follower_ids ||= Rails.cache.fetch(cache_key(:follower_ids)) {
      rest_client.follower_ids.to_a
    }
  end

  def followers
    @followers ||= Rails.cache.fetch(cache_key(:followers)) {
      users(follower_ids)
    }
  end

  def friend_ids
    @friend_ids ||= Rails.cache.fetch(cache_key(:friend_ids)) {
      rest_client.friend_ids.to_a
    }
  end

  def friends
    @friends ||= Rails.cache.fetch(cache_key(:friends)) {
      users(friend_ids)
    }
  end

  def unreturned_friends
    @unreturned_friends ||= Rails.cache.fetch(cache_key(:unreturned_friends)) {
      users(friend_ids - follower_ids)
    }
  end

  def follow!(*user_ids)
    rest_client.follow(users(user_ids.flatten))
  end

  def unfollow!(*user_ids)
    rest_client.unfollow(users(user_ids.flatten))
  end

  def followed?(user)
    friends.include?(user)
  end

  def self.upsert_by_omniauth_params!(params)
    account = find_or_initialize_by(provider: params['provider'], uid: params['uid'])
    account.provider = params['provider']
    account.uid = params['uid']
    account.nickname = params['info']['nickname']
    account.name = params['info']['name']
    account.email = params['info']['email']
    account.image_url = params['info']['image']
    account.description = params['info']['description']
    account.access_token = params['credentials']['token']
    account.access_token_secret = params['credentials']['secret']
    account.save!

    account
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
end
