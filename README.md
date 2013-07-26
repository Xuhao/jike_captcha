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

##### captcha_tag

The most useful helper is `captcha_tag`, it will render all the necessary tags.

*args:*

* `:wrapper_html`: options for wrapper tag
  * `:tag`: control wrapper tag type
* `:input_html`: options for captcha text filed tag
* `:image_html`: options for captcha img tag
  * `:src_type`: control image url type. if set to `:data_url`, will render img src as base64 encode
  * `:update`: if set to true, captcha can be update be ajax, if set to a hash, value for `:text` key in that has will used for update link content.

All the options in below are default value, except `args[:image_html][:src_type]`, it's default value is nil.

```ruby
captcha_tag wrapper_html: {
              tag: :div,
              id: 'jike_captcha_wrapper',
              class: 'jike_captcha_wrapper'
            },
            input_html: {
              id: 'jike_captcha_input',
              class: 'jike_captcha_input',
              name: 'jike_captcha_value'
            },
            image_html: {
              src_type: :data_url,
              update: { text: 'change a new one' },
              id: 'jike_captcha_image',
              class: 'jike_captcha_image'
            }
```

render:

```html
<div class="jike_captcha_wrapper" id="jike_captcha_wrapper">
  <input class="jike_captcha_input" id="jike_captcha_input" name="jike_captcha_value" type="text" />
  <img class="jike_captcha_image" data-src-type="data_url" id="jike_captcha_image" src="data:image/png;base64,iVBO......" style="cursor: pointer;" />
  <input class="jike_captcha_id" id="jike_captcha_id" name="jike_captcha_id" type="hidden" value="..." />
  <a href="javascript: void(0);" id="jike_captcha_update_link">change a new one</a>
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

##### captcha_image_tag

*args:*

  Same as `:image_html` in `captcha_tag` helper

This helper will render the captcha image.

```ruby
captcha_image_tag(
              src_type: :data_url,
              update: { text: 'change a new one' },
              id: 'jike_captcha_image',
              class: 'jike_captcha_image')
```

render:

```html
<img class="jike_captcha_image" data-src-type="data_url" id="jike_captcha_image" src="data:image/png;base64,iVBO..." style="cursor: pointer;" />
<input class="jike_captcha_id" id="jike_captcha_id" name="jike_captcha_id" type="hidden" value="c7d0973696516dc43acdeffa4baa382c" />
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

[jike_api_site]: http://open.jike.com/api/detailView?group_id=1