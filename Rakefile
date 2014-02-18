# encoding: utf-8

require "bundler/gem_tasks"
require 'rake'

begin
  gem 'rdoc'
  require 'rdoc/task'

  RDoc::Task.new do |rdoc|
    rdoc.title = "has_many_scored"
  end
rescue LoadError => e
  warn e.message
  warn "Run `gem install rdoc` to install 'rdoc/task'."
end
task :doc => :rdoc

begin
  gem 'rspec', '~> 2.4'
  require 'rspec/core/rake_task'

  RSpec::Core::RakeTask.new
rescue LoadError => e
  task :spec do
    abort "Please run `gem install rspec` to install RSpec."
  end
end

task :test    => :spec
task :default => :spec
