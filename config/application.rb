require File.expand_path('../boot', __FILE__)

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(:default, Rails.env)

module Main
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de
    config.secret_key_base = '78ccd5caba3ac945a43239946368f20de35064c24b43fcebc841eca98fd593a572805ecbf75d4af008579300b515eeb0ee49f5a578599311a68c79ed82944c51'

    config.autoload_paths += %W(#{config.root}/services)
    config.assets.paths << Rails.root.join('app', 'assets', 'fonts')
    config.assets.precompile += %w( .svg .eot .woff .ttf )


    config.generators do |g|
      g.test_framework :rspec, fixture: true
      g.fixture_replacement :factory_girl, dir: "spec/factories"
    end
  end
end
