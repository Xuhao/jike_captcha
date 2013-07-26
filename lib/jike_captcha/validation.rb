require 'active_support/core_ext/object/blank'
require 'active_support/concern'

module Jike
  module Captcha
    module Validation
      extend ActiveSupport::Concern
      extend self

      # Validate the request params
      #
      # Example:
      #   class UsersController < ApplicationController
      #     def create
      #       if captcha_valid? # Same as Jike::Captcha::Validation.captcha_valid?(params)
      #         User.create(params[:user])
      #       else
      #         redirect_to :new, notice: 'Captcha is not correct!'
      #       end
      #     end
      #   end
      def captcha_valid?(_params={})
        request_params = self.respond_to?(:params) ? (_params.presence || params) : _params
        captcha_validate(request_params[:jike_captcha_value], request_params[:jike_captcha_id])
      end

      # Validate the input value by a captcha_id
      # It's usefull to custom the captcha_tag to pass the captcha value/id with different param
      #
      # Example:
      #   class UsersController < ApplicationController
      #     def create
      #       if captcha_validate(params[:captcha_value], params[:captcha_id])
      #         User.create(params[:user])
      #       else
      #         redirect_to :new, notice: 'Captcha is not correct!'
      #       end
      #     end
      #   end
      def captcha_validate(input_value, captcha_id)
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
