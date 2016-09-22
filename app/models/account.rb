class Account < ApplicationRecord
  validates :provider, inclusion: { in: ['twitter'] }

  def rest_client
    @rest_client ||= Twitter::REST::Client.new(oauth_params)
  end

  def streaming_client
    @streaming_client ||= Twitter::Streaming::Client.new(oauth_params)
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
  end

  private

  def oauth_params
    Rails.application.secrets.twitter.merge(attributes.slice(:access_token, :access_token_secret))
  end
end
