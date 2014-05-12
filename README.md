# !!! WARNNING !!!

### Jike API has shut down, `jike_captcha` gem has been yanked!

# JikeCaptcha

[![Build Status](https://travis-ci.org/Xuhao/jike_captcha.png?branch=master)](https://travis-ci.org/Xuhao/jike_captcha)
[![Code Climate](https://codeclimate.com/github/Xuhao/jike_captcha.png)](https://codeclimate.com/github/Xuhao/jike_captcha)
[![Coverage Status](https://coveralls.io/repos/Xuhao/jike_captcha/badge.png?branch=master)](https://coveralls.io/r/Xuhao/jike_captcha?branch=master)
[![Gem Version](https://badge.fury.io/rb/jike_captcha.png)](http://badge.fury.io/rb/jike_captcha)

Captcha form [Jike API][jike_api_site], It's very simple but it's light weight and very fast. No need generate captcha image locally, so you need not install any software for it, such as ImageMagick. It get captcha form a fast and stable service clusters. It's good choice for Captcha, try it!

![Jike captcha screen shot](https://raw.github.com/Xuhao/jike_captcha/master/example/ScreenShot.png "Jike captcha screen shot")


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

#### 2. Put captcha tag in your form

```erb
<%= form_for :post do |f| %>
  <%= captcha_tag %>
  <%= f.submit %>
<% end %>
```

##### captcha_tag

The most useful helper is `captcha_tag`, it will render all the necessary tags.

*args:*

* `:wrapper_html`: options for wrapper tag
  * `:tag`: control wrapper tag type
* `:input_html`: options for captcha text filed tag
* `:image_html`: options for captcha img tag
  * `:src_type`: control image url type. if set to `:data_url`, will render img src as base64 encode
  * `:update`: if set to true, captcha can be update be ajax, if set to a hash, value for `:text` key in that has will used for update link content.

All the options at below are default value, except `args[:image_html][:src_type]`, its default value is nil.

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

#### 3. Validate captcha in controller

Submit captcha value form your form, then you can validate it in your controller use `captcha_valid?` method. It's very simple to do that.

```ruby
class UsersController < ApplicationController
  def create
    if captcha_valid? # Same as Jike::Captcha::Validation.captcha_valid?(params)
      User.create(params[:user])
    else
      redirect_to :new, notice: 'Captcha is not correct!'
    end
  end
end
```

As default, captcha value should submited by `params[:jike_captcha_value]`, another value is `params[:jike_captcha_id]`, it's generate by `captcha_tag` helper automatically.

<b>Custom captcha value param in your form</b>

You can use any param key to submit captcha value, as below:

```erb
<%= captcha_tag input_html: { name: 'my_captcha_value' } %>
```

The captcha value will submited by `params[:my_captcha_value]`. But you can't custom another value `params[:jike_captcha_id]`.

then validate in your controller like this:

```ruby
class UsersController < ApplicationController
  def create
    if captcha_validate(params[:my_captcha_value])
      User.create(params[:user])
    else
      redirect_to :new, notice: 'Captcha is not correct!'
    end
  end
end
```

#### 4. More details

[JikeCaptcha Wiki][jike_captcha_wiki]

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

[jike_api_site]: http://open.jike.com/api/detailView?group_id=1
[jike_captcha_wiki]: https://github.com/Xuhao/jike_captcha/wiki
