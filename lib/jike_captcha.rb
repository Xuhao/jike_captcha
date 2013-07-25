require "jike_captcha/version"

module Jike
  module Captcha
    CAPTCHA_ID_URL = 'http://api.jike.com/captcha/urls'
    CAPTCHA_IMAGE_URL = 'http://api.jike.com/captcha/images'
    CAPTCHA_VALIDATE_URL = 'http://api.jike.com/captcha/validation'

    # There two way to set jike app key
    # TODO: detail for those tow ways
    def self.app_key
      @app_key ||= begin
        if Module.const_defined?('Rails')
          Rails.application.config.jike_app_key if Rails.application.config.respond_to?(:jike_app_key)
        end
      end
    end

    def self.app_key=(app_key_string)
      @app_key = app_key_string
    end
  end
end

require 'jike_captcha/helpers'