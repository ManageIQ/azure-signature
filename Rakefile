require 'rake'
require 'rake/clean'
require 'rake/testtask'

CLEAN.include("**/*.gem", "**/*.rbc")

namespace :gem do
  desc 'Build the azure-signature gem'
  task :build => [:clean] do
    spec = eval(IO.read('azure-signature.gemspec'))
    Gem::Builder.new(spec).build
  end

  desc "Install the azure-signature library as a gem"
  task :install => [:build] do
    file = Dir["*.gem"].first
    sh "gem install -i #{file}"
  end
end

Rake::TestTask.new do |t|
   t.warning = true
   t.verbose = true
end

task :default => :test
