# -*- encoding: utf-8 -*-

require File.expand_path("../lib/acts_as_redis_list/version", __FILE__)

Gem::Specification.new do |gem|
  gem.name          = "acts_as_redis_list"
  gem.version       = ActsAsRedisList::VERSION
  gem.summary       = %q{An ActiveRecord plugin that combines an ordered habtm-like association with optional redis caching}
  gem.description   = %q{An ActiveRecord plugin that combines an ordered habtm-like association with optional redis caching.}
  gem.license       = "MIT"
  gem.authors       = ["Hsiu-Fan Wang"]
  gem.email         = "hfwang@porkbuns.net"
  gem.homepage      = "https://rubygems.org/gems/acts_as_redis_list"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_dependency("activerecord", ">= 3.0")
  gem.add_dependency("redis-objects", ">= 0.6.1")

  gem.add_development_dependency "pry"
  gem.add_development_dependency "sqlite3"
  gem.add_development_dependency "fakeredis"
  gem.add_development_dependency "rdoc", "~> 4.1.0"
  gem.add_development_dependency "rspec", "~> 2.4"
  gem.add_development_dependency "rubygems-tasks", "~> 0.2"
end
