# -*- encoding: utf-8 -*-
require File.expand_path('../lib/tempi/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["siddick"]
  gem.email         = ["siddick@gmail.com"]
  gem.description   = %q{Useful templates for rails}
  gem.summary       = %q{Useful templates for rails}
  gem.homepage      = "https://github.com/siddick/tempi"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "tempi"
  gem.require_paths = ["lib"]
  gem.version       = Tempi::VERSION
end
