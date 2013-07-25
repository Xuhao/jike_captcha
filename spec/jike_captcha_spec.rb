require 'spec_helper'

describe Jike::Captcha do
  it 'should have a version number' do
    Jike::Captcha::VERSION.should_not be_nil
  end

  it 'should return app_key which defined in rails application configuration file.' do
    Jike::Captcha.app_key = nil
    stub_const('Rails', Module.new)
    Rails.stub_chain('application.config.jike_app_key') { 'jike_app_key_test_sample' }
    Jike::Captcha.app_key.should eq('jike_app_key_test_sample')
  end
end
