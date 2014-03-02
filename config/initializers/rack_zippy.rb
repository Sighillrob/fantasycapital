# serve precompressed assets (.gz files) directly for static assets using rack-zippy gem.
Rails.application.config.middleware.swap(ActionDispatch::Static, Rack::Zippy::AssetServer,
                                         Rails.public_path)

