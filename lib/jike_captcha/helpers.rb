require 'httparty'
require 'active_support/json/decoding'
require 'active_support/core_ext/object/to_param'
require 'active_support/core_ext/object/to_query'
require 'active_support/concern'
require 'active_support/core_ext/hash/keys'
require 'active_support/core_ext/hash/deep_merge'
require 'active_support/core_ext/string/output_safety'
require 'active_support/core_ext/object/blank'
require 'action_view'

module Jike
  module Captcha
    module Helpers
      class AppKeyMissingError < StandardError
        def initialize
          super 'Please set app_key first! Checkout document to see how to do that.'
        end
      end
      # ActionView helpers and helper methods that can be called on Jike::Captcha::Helpers
      #
      # Example:
      #   Jike::Captcha::Helpers.captcha_image_url
      #   # => http://api.jike.com/captcha/images?app_key=<app_key>&captcha_id=<captcha_id>
      #
      #   <%= captcha_image_tag src_type: :data_url, id: :my_captcha_image %>
      #   # => <img url="data_url" src="data:image/png;base64,iVBORw0..." id="my_captcha_image" class="jike_captcha_image">
      #
      #   <%= captcha_tag wrapper_html: {tag: :span, class: :captcha_field}, input_html: {class: :my_captcha_input}, image_html: {src_type: :data_url, id: :my_captcha_image} %>
      #   # =>
      #   # <span id="jike_captcha_wrapper" class="captcha_field">
      #   #   <input id="jike_captcha_input" class="my_captcha_input" type="text" name="jike_captcha_value">
      #   #   <img id="my_captcha_image" class="jike_captcha_image" src="data:image/png;base64,iVBORw0KG....">
      #   #   <input id="jike_captcha_id" class="jike_captcha_id" type="hidden" value="b7c02131e7..." name="jike_captcha_id">
      #   # </span>
      include HTTParty, ActionView::Helpers::TagHelper, ActionView::Helpers::TextHelper, ActionView::Context
      extend self

      DEFAULT_WRAPPER_OPTIONS = { id: 'jike_captcha_wrapper', class: 'jike_captcha_wrapper' }
      DEFAULT_IMAGE_OPTIONS = { id: 'jike_captcha_image', class: 'jike_captcha_image' }
      DEFAULT_ID_OPTIONS = { id: 'jike_captcha_id', class: 'jike_captcha_id', name: 'jike_captcha_id' }
      DEFAULT_INPUT_OPTIONS = { id: 'jike_captcha_input', class: 'jike_captcha_input', name: 'jike_captcha_value' }
      DEFAULT_AJAX_LINK_OPTIONS = { id: 'jike_captcha_update_link', href: 'javascript: void(0);' }
      AJAX_LINK_TEXT = 'change another one'

      attr_accessor :captcha_image_url, :captcha_image_data, :captcha_image_data_url, :captcha_id, :captcha_image_base64

      # Return captcha image url that redirect to jike server
      #
      # Example:
      #   Jike::Captcha::Helpers.captcha_image_url
      #   # => http://api.jike.com/captcha/images?app_key=<app_key>&captcha_id=<captcha_id>
      def captcha_image_url
        @captcha_image_url ||= api_url_for(CAPTCHA_IMAGE_URL, captcha_id: captcha_id)
      end

      # Return captcha image binary data, useful for some apps except Web application
      #
      # Example:
      #   Jike::Captcha::Helpers.captcha_image_data
      #   # => "\x89PNG\r\n\x1A\n\x00\x00\......"
      def captcha_image_data
        @captcha_image_data ||= get(captcha_image_url)
      end

      # Return data url for <code><img><code> tag
      #
      # Example:
      #   Jike::Captcha::Helpers.captcha_image_data_url
      #   # => "data:image/png;base64,iVBORw0KGgoAAA......""
      def captcha_image_data_url
        @captcha_image_data_url ||= "data:image/png;base64,#{captcha_image_base64}"
      end

      # Render captcha image and captcha_id hidden field
      #
      # Example:
      #   <%= captcha_image_tag src_type: :data_url, id: :my_captcha_image %>
      #   # => <img url="data_url" src="data:image/png;base64,iVBORw0..." id="my_captcha_image" class="jike_captcha_image">
      def captcha_image_tag(options={})
        image_options = get_image_options(options)
        update_options_or_boolean = image_options.delete(:update)
        set_pointer_cursor(image_options) if update_options_or_boolean.present?
        output = ActiveSupport::SafeBuffer.new
        output << tag(:img, image_options)
        output << tag(:input, { type: :hidden, value: captcha_id }.update(DEFAULT_ID_OPTIONS))
        if update_options_or_boolean.present?
          output << ajax_link_tag(update_options_or_boolean)
          output << js_for_ajax
        end
        output
      end


      def captcha_id # :nodoc:
        @captcha_id ||= get_hash(captcha_id_url)['data']['captcha_id']
      end

      # Render captcha input text field, captcha image and captcha_id hidden field
      #
      # Example:
      #   <%= captcha_tag wrapper_html: {tag: :span, class: :captcha_field}, input_html: {class: :my_captcha_input}, image_html: {src_type: :data_url, id: :my_captcha_image} %>
      #   # =>
      #   # <span id="jike_captcha_wrapper" class="captcha_field">
      #   #   <input id="jike_captcha_input" class="my_captcha_input" type="text" name="jike_captcha_value">
      #   #   <img id="my_captcha_image" class="jike_captcha_image" src="data:image/png;base64,iVBORw0KG....">
      #   #   <input id="jike_captcha_id" class="jike_captcha_id" type="hidden" value="b7c02131e7..." name="jike_captcha_id">
      #   # </span>
      def captcha_tag(options = {})
        options.symbolize_keys!
        input_options = get_input_options(options)
        wrapper_options = get_wrapper_options(options)

        wrapper_tag = wrapper_options.delete(:tag) || :div
        content_tag wrapper_tag, wrapper_options do
          concat tag :input, { type: "text" }.update(input_options)
          concat captcha_image_tag(options.delete(:image_html) || {})
        end
      end

      def reset_captcha!
        @captcha_image_url = nil
        @captcha_image_data = nil
        @captcha_image_data_url = nil
        @captcha_id = nil
        @captcha_image_base64 = nil
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
          raise AppKeyMissingError if Jike::Captcha.app_key.blank?
          HTTParty.get(url).body
        end

        def get_hash(url)
          ::ActiveSupport::JSON.decode(get(url))
        end

        def get_wrapper_options(options)
          DEFAULT_WRAPPER_OPTIONS.merge(options.delete(:wrapper_html) || {})
        end

        def get_image_options(options)
          image_src = options[:src_type].to_s == 'data_url' ? captcha_image_data_url : captcha_image_url
          DEFAULT_IMAGE_OPTIONS.merge(src: image_src, data: { src_type: options.delete(:src_type) }).deep_merge(options)
        end

        def get_input_options(options)
          DEFAULT_INPUT_OPTIONS.merge(options.delete(:input_html) || {})
        end

        def set_pointer_cursor(options)
          options[:style] = "cursor: pointer;#{options[:style]}"
        end

        def ajax_link_tag(options_or_boolean)
          if Hash === options_or_boolean
            return '' if options_or_boolean.key?(:text) and options_or_boolean[:text].is_a?(FalseClass)
            content_tag :a, options_or_boolean.delete(:text), options_or_boolean.merge( DEFAULT_AJAX_LINK_OPTIONS )
          else
            content_tag :a, AJAX_LINK_TEXT, DEFAULT_AJAX_LINK_OPTIONS
          end
        end

        def js_for_ajax
          js = <<-JAVASCRIPT
            <script type="text/javascript">
              //<![CDATA[
                $(function(){
                  $('body').on('click', 'img#jike_captcha_image, a#jike_captcha_update_link', function(event) {
                    var imageType, $captchaInput, $captchaImage, $captchaId;
                    $captchaInput = $('input#jike_captcha_input');
                    $captchaImage = $('img#jike_captcha_image');
                    $captchaId = $('input#jike_captcha_id');
                    imageType = $captchaImage.data('src-type');
                    $.getJSON('/jike_captcha/get_captcha.json', {image_type: imageType}, function(data) {
                      $captchaInput.val('');
                      $captchaImage.attr('src', decodeURIComponent(data.captcha_image));
                      $captchaId.val(data.captcha_id);
                    });
                  });
                });
              //]]>
            </script>
          JAVASCRIPT
          js.html_safe
        end
    end
  end
end