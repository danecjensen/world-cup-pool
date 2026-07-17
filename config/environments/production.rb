require "active_support/core_ext/integer/time"

Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # Code is not reloaded between requests.
  config.enable_reloading = false

  # Eager load code on boot. This eager loads most of Rails and
  # your application in memory, allowing both threaded web servers
  # and those relying on copy on write to perform better.
  # Rake tasks automatically ignore this option for performance.
  config.eager_load = true

  # Full error reports are disabled and caching is turned on.
  config.consider_all_requests_local = false
  config.action_controller.perform_caching = true

  # Ensures that a master key has been made available in ENV["RAILS_MASTER_KEY"], config/master.key, or an environment
  # key such as config/credentials/production.key. This key is used to decrypt credentials (and other encrypted files).
  # config.require_master_key = true

  # Disable serving static files from `public/`, relying on NGINX/Apache to do so instead.
  # config.public_file_server.enabled = false

  # Compress CSS using a preprocessor.
  # config.assets.css_compressor = :sass

  # Do not fall back to assets pipeline if a precompiled asset is missed.
  config.assets.compile = false

  # Enable serving of images, stylesheets, and JavaScripts from an asset server.
  # config.asset_host = "http://assets.example.com"

  # Specifies the header that your server uses for sending files.
  # config.action_dispatch.x_sendfile_header = "X-Sendfile" # for Apache
  # config.action_dispatch.x_sendfile_header = "X-Accel-Redirect" # for NGINX

  # Store uploaded files in cloud object storage (see config/storage.yml).
  # Defaults to Amazon S3 because hosts like Heroku have an ephemeral file
  # system — local disk would lose uploads on every deploy/restart. Set
  # ACTIVE_STORAGE_SERVICE=local to override (not recommended in production).
  config.active_storage.service = ENV.fetch("ACTIVE_STORAGE_SERVICE", "amazon").to_sym

  # Mount Action Cable outside main process or domain.
  # config.action_cable.mount_path = nil
  # config.action_cable.url = "wss://example.com/cable"
  # config.action_cable.allowed_request_origins = [ "http://example.com", /http:\/\/example.*/ ]

  # Assume all access to the app is happening through a SSL-terminating reverse proxy.
  # Can be used together with config.force_ssl for Strict-Transport-Security and secure cookies.
  # config.assume_ssl = true

  # Force all access to the app over SSL, use Strict-Transport-Security, and use secure cookies.
  config.force_ssl = true

  # Skip http-to-https redirect for the default health check endpoint.
  # config.ssl_options = { redirect: { exclude: ->(request) { request.path == "/up" } } }

  # Log to STDOUT by default
  config.logger = ActiveSupport::Logger.new(STDOUT)
    .tap  { |logger| logger.formatter = ::Logger::Formatter.new }
    .then { |logger| ActiveSupport::TaggedLogging.new(logger) }

  # Prepend all log lines with the following tags.
  config.log_tags = [ :request_id ]

  # "info" includes generic and useful information about system operation, but avoids logging too much
  # information to avoid inadvertent exposure of personally identifiable information (PII). If you
  # want to log everything, set the level to "debug".
  config.log_level = ENV.fetch("RAILS_LOG_LEVEL", "info")

  # Use a different cache store in production.
  # config.cache_store = :mem_cache_store

  # Use a real queuing backend for Active Job (and separate queues per environment).
  # config.active_job.queue_adapter = :resque
  # config.active_job.queue_name_prefix = "world_cup_pool_production"

  # Disable caching for Action Mailer templates even if Action Controller
  # caching is enabled.
  config.action_mailer.perform_caching = false

  if ENV["APP_HOST"].present?
    config.action_mailer.default_url_options = { host: ENV["APP_HOST"], protocol: "https" }
  end

  # Deliver mail (e.g. Devise password-reset emails) over SMTP.
  #
  # This is provider-agnostic: it reads generic SMTP_* env vars if you set
  # them, and otherwise falls back to the credentials that the Heroku SendGrid
  # add-on provisions automatically (SENDGRID_USERNAME / SENDGRID_PASSWORD).
  #
  # Easiest setup on Heroku:
  #   heroku addons:create sendgrid:starter
  #   heroku config:set APP_HOST=your-app.herokuapp.com
  # That's it — no other config needed for the SendGrid path.
  smtp_address  = ENV["SMTP_ADDRESS"].presence || "smtp.sendgrid.net"
  smtp_username = ENV["SMTP_USERNAME"].presence || ENV["SENDGRID_USERNAME"].presence
  smtp_password = ENV["SMTP_PASSWORD"].presence || ENV["SENDGRID_PASSWORD"].presence

  if smtp_username.present? && smtp_password.present?
    config.action_mailer.delivery_method = :smtp
    config.action_mailer.perform_deliveries = true
    # Surface delivery errors in the logs instead of failing silently.
    config.action_mailer.raise_delivery_errors = true
    config.action_mailer.smtp_settings = {
      address:              smtp_address,
      port:                 ENV.fetch("SMTP_PORT", 587).to_i,
      domain:               ENV["SMTP_DOMAIN"].presence || ENV["APP_HOST"].presence || "herokuapp.com",
      user_name:            smtp_username,
      password:             smtp_password,
      authentication:       :plain,
      enable_starttls_auto: true
    }
  end

  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation cannot be found).
  config.i18n.fallbacks = true

  # Don't log any deprecations.
  config.active_support.report_deprecations = false

  # Do not dump schema after migrations.
  config.active_record.dump_schema_after_migration = false

  # Only use :id for inspections in production.
  config.active_record.attributes_for_inspect = [ :id ]

  # Enable DNS rebinding protection and other `Host` header attacks.
  # config.hosts = [
  #   "example.com",     # Allow requests from example.com
  #   /.*\.example\.com/ # Allow requests from subdomains like `www.example.com`
  # ]
  # Skip DNS rebinding protection for the default health check endpoint.
  # config.host_authorization = { exclude: ->(request) { request.path == "/up" } }
end
