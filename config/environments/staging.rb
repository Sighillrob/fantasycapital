
# use 'production' environment as baseline. Just change some variables as necessary. We want staging environment
#  to be as similar to production as possible.
require File.expand_path("./config/environments/production.rb")

Main::Application.configure do

  # Host for static assets in STAGING environment - Amazon CloudFront (thru AWS panel)
  config.action_controller.asset_host = "d1jv7n5pq9c84n.cloudfront.net"
end

Rails.configuration.app_name = "fantasycapital-stg"
