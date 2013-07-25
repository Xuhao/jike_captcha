require 'httparty'
require 'open-uri'
require 'active_support/json/decoding'
require 'active_support/core_ext/object/to_param'
require 'active_support/core_ext/object/to_query'
require 'action_view/helpers/tag_helper'

module Jike
  module Captcha
    module Helpers
      include HTTParty
      extend self

      def captcha_image_url
        @captcha_image_url ||= api_url_for(CAPTCHA_IMAGE_URL, captcha_id: captcha_id)
      end

      def captcha_image_data
        @captcha_image_data ||= HTTParty.get(captcha_image_url).body
      end

      def captcha_image_base64
        @captcha_image_base64 ||= Base64.encode64(captcha_image_data)
      end

      def captcha_image_data_url
        @captcha_image_data_url ||= "data:image/png;base64,#{captcha_image_base64}"
      end

      def captcha_id
        @captcha_id ||= get(captcha_id_url)['data']['captcha_id']
      end

      def captcha_image_tag(options={})
        wrapper_options = ready_wrapper_options(options.delete(:wrapper_html))
        image_src = options.delete(:src_type).to_s == 'url' ? captcha_image_url : captcha_image_data_url
        image_options = {src: image_src}.merge(options.delete(:image_html) || {})
        wrapper_tag = wrapper_options.delete(:wrapper) || :div

        content_tag wrapper_tag, wrapper_options do
          concat content_tag :img, image_options
          concat content_tag :input, id: :jike_captcha_id,  name: :jike_captcha_id, type: :hidden, value: captcha_id
        end
      end

      private
        def captcha_id_url
          api_url_for(CAPTCHA_ID_URL)
        end

        def api_url_for(base_url, params={})
          params.merge!(app_key: Jike::Captcha.app_key)
          "#{base_url}?#{params.to_param}"
        end

        def get(url)
          ::ActiveSupport::JSON.decode(HTTParty.get(url).body)
        end

        def ready_wrapper_options(options)
          {id: 'jike_captcha_wrapper', class: 'jike_captcha_wrapper'}.merge(options || {})
        end
    end
  end
end

ActionView::Base.__send__ :include, Jike::Captcha::Helpers