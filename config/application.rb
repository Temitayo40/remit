require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Remit
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 8.1

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: %w[assets tasks])

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # All owners and drivers are in Nigeria. "Today" (for due entries, "who
    # hasn't paid today", receipts) must mean the Lagos calendar day, not UTC's.
    # The database still stores timestamps in UTC; Rails converts on read/write.
    # Use Time.current / Date.current in code, never Time.now / Date.today
    # (those use the server's clock zone and ignore this setting).
    config.time_zone = "Africa/Lagos"
    # config.eager_load_paths << Rails.root.join("extras")
  end
end
