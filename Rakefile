require 'rubygems'
require 'cucumber'
require 'cucumber/rake/task'
require "bundler/gem_tasks"

Cucumber::Rake::Task.new(:features) do |t|
  t.cucumber_opts = "features --format pretty --publish"
end

task :default => [ :build , 'install:local' , :features ]
task :test => :features
