Rails.application.config.middleware.use OmniAuth::Builder do
  provider :twitter,
           Rails.application.secrets.twitter['consumer_key'],
           Rails.application.secrets.twitter['consumer_secret']
end
