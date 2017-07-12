# -*- encoding: utf-8 -*-

$LOAD_PATH.push File.expand_path('../lib', __FILE__)

require File.expand_path('lib/carrierwave/nos/version')

Gem::Specification.new do |spec|
  spec.name          = 'carrierwave-nos'
  spec.version       = CarrierWave::Nos::VERSION
  spec.authors       = ['Shurui Yang']
  spec.email         = ['yangshurui1023@gmail.com']
  spec.summary       = 'NOS support for CarrierWave.'
  spec.description   = 'NOS support for CarrierWave.'
  spec.homepage      = ''
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.require_paths = ['lib']

  spec.add_dependency 'carrierwave', ['~> 1.0']
  spec.add_dependency 'rest-client'

  spec.add_development_dependency 'sqlite3'
  spec.add_development_dependency 'activerecord'
  spec.add_development_dependency 'rspec', '~> 3.0'
end
