require 'rake'
require 'rake/clean'
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec)

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

task :default => :spec
