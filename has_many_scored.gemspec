# encoding: utf-8

require File.expand_path("../lib/has_many_scored/version", __FILE__)

Gem::Specification.new do |gem|
  gem.name          = "has_many_scored"
  gem.version       = HasManyScored::VERSION
  gem.summary       = %q{An ActiveRecord plugin that combines an ordered habtm-like association with optional redis caching}
  gem.description   = %q{An ActiveRecord plugin that combines an ordered habtm-like association with optional redis caching.}
  gem.license       = "MIT"
  gem.authors       = ["Hsiu-Fan Wang"]
  gem.email         = "hfwang@porkbuns.net"
  gem.homepage      = "https://rubygems.org/gems/has_many_scored"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_dependency("activerecord", ">= 3.0", "<= 4.0.2")
  gem.add_dependency("redis-objects", ">= 0.6.1")

  gem.add_development_dependency "pry"
  gem.add_development_dependency "sqlite3"
  gem.add_development_dependency "fakeredis"
  gem.add_development_dependency "rdoc", "~> 4.1.0"
  gem.add_development_dependency "rspec", "~> 2.4"
  gem.add_development_dependency "rubygems-tasks", "~> 0.2"
end
