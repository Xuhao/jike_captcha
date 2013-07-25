require 'spec_helper'

describe Jike::Captcha::Helpers do
  before(:each) { Jike::Captcha.app_key = 'ba02964ba79438ec' }
  it 'should return captcha image url that redirect to jike server when call captcha_url method' do
    image_url = Jike::Captcha::Helpers.captcha_image_url
    image_url.should be_a(String)
    image_url.include?(Jike::Captcha::CAPTCHA_IMAGE_URL).should be_true
    image_url.include?("captcha_id=").should be_true
  end

  it 'should return a captcha id when call captcha_id method' do
    captcha_id = Jike::Captcha::Helpers.captcha_id
    captcha_id.should be_a(String)
    captcha_id.size.should eq(32)
    captcha_id.include?("captcha_id=").should be_false
  end

  it 'should return binary data for captcha image when all captcha_image_data' do
    image_data = Jike::Captcha::Helpers.captcha_image_data
    image_data.encoding.name.should eq('ASCII-8BIT')
  end

  it 'should return base64 data for captcha image when call captcha_image_base64' do
    Jike::Captcha::Helpers.captcha_image_base64.should =~ /\A[\w\+\/]+/
  end

  it 'should return data url for captcha image when call captcha_image_data_url' do
    Jike::Captcha::Helpers.captcha_image_data_url.should =~ /\Adata:image\/png;base64,+/
  end
end