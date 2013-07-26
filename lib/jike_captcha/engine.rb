require "rails"

module Jike
  module Captcha
    class Engine < Rails::Engine
      initializer "Actionpack extensions" do
        ActiveSupport.on_load :action_view do
          ActionView::Base.send :include, Jike::Captcha::Helpers
        end

        ActiveSupport.on_load :action_controller do
          ActionController::Metal.send :include, Jike::Captcha::Validation
        end
      end
    end
  end
end