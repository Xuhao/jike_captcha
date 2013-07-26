Rails.application.routes.draw do
  get '/jike_captcha/get_captcha', to: Jike::Captcha::GetCaptchaController.action(:index)
end
