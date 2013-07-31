require 'spec_helper'

describe Jike::Captcha::Validation do
  let(:params1) { { jike_captcha_value: 'captcha_value', jike_captcha_id: 'captcha_id' }}
  let(:params2) { { jike_captcha_value: '', jike_captcha_id: nil }}
  let(:params3) { { captcha_id: 'captcha_id' }}

  it 'should validate captcha value in params when call captcha_valid?' do 
    Jike::Captcha::Validation.captcha_valid?(params1).should be_false
    Jike::Captcha::Validation.captcha_valid?(params2).should be_false
    Jike::Captcha::Validation.captcha_valid?(params3).should be_false
  end

  it 'should check the given captcha value and id and return boolean' do
    Jike::Captcha::Validation.captcha_validate(params1[:jike_captcha_value], params1[:jike_captcha_id]).class.should satisfy{|k| [TrueClass, FalseClass].include?(k)}
    Jike::Captcha::Helpers.stub(:send).and_raise
    Jike::Captcha::Validation.captcha_validate(params1[:jike_captcha_value], params1[:jike_captcha_id]).should be_false
  end
end