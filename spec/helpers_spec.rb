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

  it 'should return data url for captcha image when call captcha_image_data_url' do
    Jike::Captcha::Helpers.captcha_image_data_url.should =~ /\Adata:image\/png;base64,+/
  end

  it 'should render captcha image and hidden input to value current captcha id when call captcha_image_tag' do
    image_tag = Jike::Captcha::Helpers.captcha_image_tag(name: 'my_captcha_image')
    image_tag.should =~ /\A<img+/
    image_tag.should =~ /<input+/
    image_tag.include?('class="jike_captcha_image"').should be_true
    image_tag.include?('id="jike_captcha_image"').should be_true
    image_tag.include?('class="jike_captcha_id"').should be_true
    image_tag.include?('id="jike_captcha_id"').should be_true
    image_tag.include?('name="my_captcha_image"').should be_true
    Jike::Captcha::Helpers.captcha_image_tag(id: 'my_captcha_image').include?('id="my_captcha_image"').should be_true
  end

  it 'should render captcha input and captcha image when call captcha_tag method' do
    captcha_tag = Jike::Captcha::Helpers.captcha_tag(wrapper_html: {tag: :div})
    captcha_tag1 = Jike::Captcha::Helpers.captcha_tag(
      wrapper_html: {tag: :span, class: 'my_captcha_wrapper'},
      input_html: {id: 'my_captcha_input'},
      image_html: {name: 'my_captcha_image', class: 'test_class'}
    )
    captcha_tag.include?('class="jike_captcha_wrapper"').should be_true
    captcha_tag.include?('id="jike_captcha_wrapper"').should be_true
    captcha_tag.should =~ /\A<div+/
    captcha_tag.should =~ /<img+/
    captcha_tag.should =~ /<input+/
    captcha_tag.include?('class="jike_captcha_image"').should be_true
    captcha_tag.include?('id="jike_captcha_image"').should be_true
    captcha_tag.include?('class="jike_captcha_id"').should be_true
    captcha_tag.include?('id="jike_captcha_id"').should be_true

    captcha_tag1.should =~ /\A<span+/
    captcha_tag1.include?('class="test_class"').should be_true
    captcha_tag1.include?('name="my_captcha_image"').should be_true
    captcha_tag1.include?('class="my_captcha_wrapper"').should be_true
    captcha_tag1.include?('id="my_captcha_input"').should be_true
  end
end