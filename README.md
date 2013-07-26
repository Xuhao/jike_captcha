# JikeCaptcha

Captcha form [jike API][jike_api_site], It's very simple but it's light weight and very fast. No need generate captcha image locally, so you need not install any software for it, such as ImageMagick. It get captcha form a fast and stable service clusters. It's good choice for Captcha, try it!

## Installation

Add this line to your application's Gemfile:

    gem 'jike_captcha'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install jike_captcha

## Usage

#### 1. Get your app_key

Before use it, you need get you app_key form [Jike API site](http://open.jike.com/).

Once get your app_key, you need tell JikeCaptcha what kind of app_key you got, there are two ways:

One: create a file in config/initializers/jike_captcha.rb with below code:

```ruby
# config/initializers/jike_captcha.rb
Jike::Captcha.app_key = "<your_app_key>"
```

Two: set app_key in config/application.rb:

```ruby
config.jike_app_key = '<your_app_key>'
```

#### 2. Put captcha tag in you form

JikeCaptcha provide some helpers to render the captcha input box, captcha image and others.

#####captcha_tag

The most useful helper is `captcha_tag`, it will render all the necessary tags.
  
```ruby
captcha_tag wrapper_html: {tag: :span, class: :captcha_field}, input_html: {class: :my_captcha_input}, image_html: {src_type: :data_url, update: { text: 'change a new one'}, id: :my_captcha_image}
```
render:

```html
<span id="jike_captcha_wrapper" class="captcha_field">
  <input type="text" name="jike_captcha_value" id="jike_captcha_input" class="my_captcha_input">
  <img style="cursor: pointer;" src="data:image/png;base64,iVB..." id="my_captcha_image" data-src-type="data_url" class="jike_captcha_image">
  <input type="hidden" value="4eef9e57d4b0b6571f7474641eb19193" name="jike_captcha_id" id="jike_captcha_id" class="jike_captcha_id">
  <a id="jike_captcha_update_link" href="javascript: void(0);">change a new one</a>
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
</div>
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

[jike_api_site]: http://open.jike.com/api/detailView?group_id=1