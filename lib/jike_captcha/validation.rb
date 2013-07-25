require 'active_support/core_ext/object/blank'
require 'active_support/concern'

module Jike
  module Captcha
    module Validation
      extend ActiveSupport::Concern
      extend self

      # TODO: usage
      def captcha_valid?(_params={})
        request_params = self.respond_to?(:params) ? (_params.presence || params) : _params
        validate(request_params[:jike_captcha_value], request_params[:jike_captcha_id])
      end

      # TODO: usage
      def validate(input_value, captcha_id)
        return false if input_value.blank? or captcha_id.blank?
        response = Jike::Captcha::Helpers.send(:get_hash, validate_url(input_value, captcha_id))
        !!response['data']
      rescue
        false
      end

      private
        def validate_url(input_value, captcha_id)
          Jike::Captcha::Helpers.send(:api_url_for, CAPTCHA_VALIDATE_URL, captcha_id: captcha_id, input: input_value)
        end
    end
  end
end

if Module.const_defined?('ActionController')
  ActionController::Metal.__send__ :include, Jike::Captcha::Validation
end
