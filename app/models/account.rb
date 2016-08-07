class Account < ApplicationRecord
  def rest_client
    case provider
    when 'twitter'
      Twitter::REST::Client.new(twitter_oauth_params)
    else
      nil
    end
  end

  def streaming_client
    case provider
    when 'twitter'
      Twitter::Streaming::Client.new(twitter_oauth_params)
    else
      nil
    end
  end

  def self.upsert_by_omniauth_params(params)
    unique_params = { provider: params['provider'], uid: params['uid'] }
    account = find_by(unique_params) || new(unique_params)
    account.provider = params['provider']
    account.uid = params['uid']
    account.nickname = params['info']['nickname']
    account.name = params['info']['name']
    account.email = params['info']['email']
    account.image_url = params['info']['image']
    account.description = params['info']['description']
    account.access_token = params['credentials']['token']
    account.access_token_secret = params['credentials']['secret']
    
    account if account.save
  end
  
  private
  
  def twitter_oauth_params
    {
      consumer_key: Rails.application.secrets.twitter['consumer_key'],
      consumer_secret: Rails.application.secrets.twitter['consumer_secret'],
      access_token: access_token,
      access_token_secret: access_token_secret
    }
  end
end
