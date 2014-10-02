require File.expand_path('../boot', __FILE__)

require 'rails/all'

# you've limited to :test, :development, or :production.
Bundler.require(:default, Rails.env)

require File.expand_path('../../lib/delimiter', __FILE__)

module Dubsar
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

    config.active_record.schema_format = :sql
    config.assets.precompile += [
      'main_manifest.css', 'main_manifest.js',
      'mobile_manifest.css', 'mobile_manifest.js', 
      'qunit_manifest.css', 'qunit_manifest.js',
      'cpyn_manifest.css', 'cpyn_manifest.js'
    ]
  end
end
