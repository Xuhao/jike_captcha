require 'spec_helper'

describe Jike::Captcha do
  it 'should have a version number' do
    Jike::Captcha::VERSION.should_not be_nil
  end
end
