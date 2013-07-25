# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'jike_captcha/version'

Gem::Specification.new do |spec|
  spec.name          = "jike_captcha"
  spec.version       = Jike::Captcha::VERSION
  spec.authors       = ["Xuhao"]
  spec.email         = ["xuhao@rubyfans.com"]
  spec.description   = %q{Captcha form Jike API}
  spec.summary       = %q{Captcha form Jike API}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency 'httparty'
  spec.add_dependency 'activesupport'
  spec.add_dependency 'actionpack'
  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
end
