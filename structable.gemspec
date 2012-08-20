# I don't know why dose occur errors below.
#  require_relative 'lib/structable/version'
require File.expand_path('../lib/structable/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ['Kenichi Kamiya']
  gem.email         = ['kachick1+ruby@gmail.com']
  gem.description   = %q{Provide "Struct" like API}
  gem.summary       = %q{Member aliasing, Inheritable}
  gem.homepage      = 'https://github.com/kachick/structable'

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features|declare)/})
  gem.name          = 'structable'
  gem.require_paths = ['lib']
  gem.version       = Structable::VERSION
end
