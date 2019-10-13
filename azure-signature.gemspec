require 'rubygems'

Gem::Specification.new do |gem|
  gem.name      = 'azure-signature'
  gem.version   = '0.3.0'
  gem.author    = 'Daniel J. Berger'
  gem.license   = 'Apache-2.0'
  gem.email     = 'djberg96@gmail.com'
  gem.homepage  = 'http://github.com/djberg96/azure-signature'
  gem.summary   = 'Generate authentication signatures for Azure'
  gem.test_file = 'test/test_signature.rb'
  gem.files     = Dir['**/*'].reject{ |f| f.include?('git') }

  gem.extra_rdoc_files = ['README', 'CHANGELOG.md', 'MANIFEST']
   
  gem.add_dependency('addressable', '~> 2')
  gem.add_dependency('activesupport', '>= 4.2.2')
  gem.add_development_dependency('test-unit', '~> 3')

  gem.description = <<-EOF
    The azure-signature library generates storage signatures for
    Microsoft Azure's cloud platform. You can use this to access
    Azure storage services - tables, blobs, queues and files.
  EOF

  spec.metadata = {
    'homepage_uri'      => 'https://github.com/djberg96/azure-signature',
    'bug_tracker_uri'   => 'https://github.com/djberg96/azure-signature/issues',
    'changelog_uri'     => 'https://github.com/djberg96/azure-signature/blob/master/CHANGELOG.md',
    'documentation_uri' => 'https://github.com/djberg96/azure-signature/wiki',
    'source_code_uri'   => 'https://github.com/djberg96/azure-signature',
    'wiki_uri'          => 'https://github.com/djberg96/azure-signature/wiki'
  }
end
