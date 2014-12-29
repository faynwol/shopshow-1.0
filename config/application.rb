require File.expand_path('../boot', __FILE__)

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Shopshow
  class Application < Rails::Application
    config.autoload_paths += %W(#{config.root}/app/uploaders)
    config.autoload_paths += %W(#{config.root}/lib)
    config.autoload_paths += %W(#{config.root}/app/grape)
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    config.time_zone = 'Beijing'

    config.assets.precompile += %w( 
      cpanel.css 
      html5shiv.js 
      respond.min.js 
      bootstrap-ie7.css 
      chat.js
      chat_options.js
      chat.css
      materials.js
      mobile/app.css
      mobile/app.js
      mobile/register.js
      mobile/shopping_cart.js
      delivery/app.css
      delivery/app.js
      delivery/live_shows.js
      delivery/products.js
      delivery/orders.js
      bootstrap-datetimepicker.min.css
      bootstrap-datetimepicker.min.js
    )

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    config.i18n.available_locales = [:"zh-CN", :zh]
    config.i18n.default_locale = :'zh-CN'
    config.i18n.enforce_available_locales = false

    config.action_mailer.delivery_method = :smtp  
    config.action_mailer.smtp_settings = {
      :address => "smtp.exmail.qq.com",
      :port => "25",
      :domain => "shopshow.com",
      :authentication => :login,
      :user_name => "no-reply@shopshow.com",
      :password => "shopshow123456",
      :enable_starttls_auto => true
    }           
  end
end
