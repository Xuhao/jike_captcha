module Jike::Captcha
  class GetCaptchaController < ::ActionController::Metal

    def index
      jike_helper = Jike::Captcha::Helpers
      jike_helper.reset_captcha!
      image = (params[:image_type] == 'data_url' ? jike_helper.captcha_image_data_url : jike_helper.captcha_image_url)
      self.response_body = { captcha_image: image, captcha_id: jike_helper.captcha_id }.to_json
    end
  end
end