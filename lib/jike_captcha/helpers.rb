require 'httparty'
require 'active_support/json/decoding'
require 'active_support/core_ext/object/to_param'
require 'active_support/core_ext/object/to_query'
require 'action_view/helpers/tag_helper'
require 'active_support/core_ext/hash/keys'

module Jike
  module Captcha
    module Helpers
      include HTTParty
      extend self

      DEFAULT_WRAPPER_OPTIONS = { id: 'jike_captcha_wrapper', class: 'jike_captcha_wrapper' }
      DEFAULT_IMAGE_OPTIONS = { id: 'jike_captcha_image', class: 'jike_captcha_image' }
      DEFAULT_ID_OPTIONS = { id: 'jike_captcha_id', class: 'jike_captcha_id', name: 'jike_captcha_id' }
      DEFAULT_INPUT_OPTIONS = { id: 'jike_captcha_input', class: 'jike_captcha_input', name: 'jike_captcha_value' }

      # TODO: usage
      def captcha_image_url
        @captcha_image_url ||= api_url_for(CAPTCHA_IMAGE_URL, captcha_id: captcha_id)
      end

      # TODO: usage
      def captcha_image_data
        @captcha_image_data ||= get(captcha_image_url)
      end

      # TODO: usage
      def captcha_image_data_url
        @captcha_image_data_url ||= "data:image/png;base64,#{captcha_image_base64}"
      end

      def captcha_id
        @captcha_id ||= get_hash(captcha_id_url)['data']['captcha_id']
      end

      # TODO: usage
      def captcha_image_tag(options={})
        options.symbolize_keys!
        image_options = get_image_options(options)

        tag(:img, image_options) +
        tag(:input, { type: :hidden, value: captcha_id }.update(DEFAULT_ID_OPTIONS))
      end

      # TODO: usage
      def captcha_tag(options = {})
        options.symbolize_keys!
        input_options = get_input_options(options)
        wrapper_options = get_wrapper_options(options)
        wrapper_tag = wrapper_options.delete(:tag) || :div

        content_tag wrapper_tag, wrapper_options do
          concat tag :input, { type: "text" }.update(input_options)
          concat captcha_image_tag(options)
        end
      end

      private
        def captcha_image_base64
          @captcha_image_base64 ||= Base64.encode64(captcha_image_data)
        end

        def captcha_id_url
          api_url_for(CAPTCHA_ID_URL)
        end

        def api_url_for(base_url, params={})
          params.merge!(app_key: Jike::Captcha.app_key)
          "#{base_url}?#{params.to_param}"
        end

        def get(url)
          HTTParty.get(url).body
        end

        def get_hash(url)
          ::ActiveSupport::JSON.decode(get(url))
        end

        def get_wrapper_options(options)
          DEFAULT_WRAPPER_OPTIONS.merge(options.delete(:wrapper_html) || {})
        end

        def get_image_options(options)
          image_src = options.delete(:src_type).to_s == 'data_url' ? captcha_image_data_url : captcha_image_url
          DEFAULT_IMAGE_OPTIONS.merge(src: image_src).merge(options.delete(:image_html) || {})
        end

        def get_input_options(options)
          DEFAULT_INPUT_OPTIONS.merge(options.delete(:input_html) || {})
        end
    end
  end
end

ActionView::Base.__send__ :include, Jike::Captcha::Helpers