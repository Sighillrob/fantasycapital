if Rails.env.staging? or Rails.env.staging?
  Airbrake.configure do |config|
    config.api_key = 'a847c662a8ed86b96b30e146364d6e7a'
  end
end
