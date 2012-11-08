# -*- encoding: utf-8 -*-
require File.expand_path('../lib/nebulachain/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["linyows"]
  gem.email         = ["linyows@gmail.com"]
  gem.description   = %q{ Gem to add follow/block, like/dislike features if you're using rails3 with mongoid3 }
  gem.summary       = %q{ Add follow/block, like/dislike features to rails3 + mongoid3 }
  gem.homepage      = 'https://github.com/linyows/nebulachain'

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "nebulachain"
  gem.require_paths = ["lib"]
  gem.version       = Nebulachain::VERSION
end
