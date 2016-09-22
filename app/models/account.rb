class Account < ApplicationRecord
  validates :provider, inclusion: { in: ['twitter'] }

  def follower_ids
    @follower_ids ||= Rails.cache.fetch(cache_key(:follower_ids)) {
      rest_client.follower_ids.to_a
    }
  end

  def followers
    @followers ||= Rails.cache.fetch(cache_key(:followers)) {
      rest_client.users(follower_ids)
    }
  end

  def friend_ids
    @friend_ids ||= Rails.cache.fetch(cache_key(:friend_ids)) {
      rest_client.friend_ids.to_a
    }
  end

  def friends
    @followers ||= Rails.cache.fetch(cache_key(:friends)) {
      rest_client.users(friend_ids)
    }
  end

  def unreturned_friends
    @unreturned_friends ||= Rails.cache.fetch(cache_key(:unreturned_friends)) {
      rest_client.users(friend_ids - follower_ids)
    }
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
end
