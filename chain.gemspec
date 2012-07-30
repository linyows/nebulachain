# -*- encoding: utf-8 -*-
require File.expand_path('../lib/chain/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["linyows"]
  gem.email         = ["linyows@gmail.com"]
  gem.description   = %q{ Gem to add basic 'relationships' features if you're using rails3 with mongoid3 }
  gem.summary       = %q{ Add basic 'relationships' features to rails3 + mongoid3 }
  gem.homepage      = 'https://github.com/linyows/chain'

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "chain"
  gem.require_paths = ["lib"]
  gem.version       = Chain::VERSION
end
