module Jike::Captcha
  class GetCaptchaController < ::ActionController::Metal

    def index
      Jike::Captcha::Helpers.reset_captcha!
      image = (params[:image_type] == 'data_url' ? Jike::Captcha::Helpers.captcha_image_data_url : Jike::Captcha::Helpers.captcha_image_url)
      self.response_body = {captcha_image: image, captcha_id: Jike::Captcha::Helpers.captcha_id}.to_json
    end
  end
end