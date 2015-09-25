require 'rake'
require 'rake/clean'
require 'rake/testtask'

CLEAN.include("**/*.gem", "**/*.rbc")

namespace :gem do
  desc 'Create the azure-signature gem'
  task :create => [:clean] do
    require 'rubygems/package'
    spec = eval(IO.read('azure-signature.gemspec'))
    Gem::Package.build(spec)
  end

  desc "Install the azure-signature library as a gem"
  task :install => [:create] do
    file = Dir["*.gem"].first
    sh "gem install -l #{file}"
  end
end

Rake::TestTask.new do |t|
   t.warning = true
   t.verbose = true
end

task :default => :test
