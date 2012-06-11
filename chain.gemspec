# -*- encoding: utf-8 -*-
$:.push File.expand_path('../lib', __FILE__)
require 'chain/version'

Gem::Specification.new do |s|
  s.name        = 'chain'
  s.version     = Chain::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ['linyows']
  s.email       = ['linyows@gmail.com']
  s.homepage    = 'https://github.com/linyows/chain'
  s.summary     = %q{ Add basic 'relationships' features to rails3 + mongoid }
  s.description = %q{ Gem to add basic 'relationships' features if you're using rails3 with mongoid }

  s.rubyforge_project = 'chain'

  s.add_dependency 'mongoid'
  s.add_dependency 'bson_ext'
  s.add_development_dependency 'database_cleaner'
  s.add_development_dependency 'rspec'

  s.files         = `git ls-files`.split('\n')
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split('\n')
  s.executables   = `git ls-files -- bin/*`.split('\n').map{ |f| File.basename(f) }
  s.require_paths = ['lib']
end
