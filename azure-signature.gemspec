require 'rubygems'

Gem::Specification.new do |gem|
  gem.name      = 'azure-signature'
  gem.version   = '0.3.0'
  gem.author    = 'Daniel J. Berger'
  gem.license   = 'Apache 2.0'
  gem.email     = 'djberg96@gmail.com'
  gem.homepage  = 'http://github.com/djberg96/azure-signature'
  gem.summary   = 'Generate authentication signatures for Azure'
  gem.test_file = 'test/test_signature.rb'
  gem.files     = Dir['**/*'].reject{ |f| f.include?('git') }

  gem.extra_rdoc_files = ['README', 'CHANGES', 'MANIFEST']
   
  gem.add_dependency('addressable')
  gem.add_dependency('activesupport')
  gem.add_development_dependency('test-unit')

  gem.description = <<-EOF
    The azure-signature library generates storage signatures for
    Microsoft Azure's cloud platform. You can use this to access
    Azure storage services - tables, blobs, queues and files.
  EOF
end
