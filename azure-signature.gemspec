require 'rubygems'

Gem::Specification.new do |spec|
  spec.name      = 'azure-signature'
  spec.version   = '0.3.0'
  spec.author    = 'Daniel J. Berger'
  spec.license   = 'Apache-2.0'
  spec.email     = 'djberg96@gmail.com'
  spec.homepage  = 'http://github.com/djberg96/azure-signature'
  spec.summary   = 'Generate authentication signatures for Azure'
  spec.test_file = 'spec/azure_signature_spec.rb'
  spec.files     = Dir['**/*'].reject{ |f| f.include?('git') }

  spec.extra_rdoc_files = ['README.md', 'CHANGELOG.md', 'MANIFEST.md']
   
  spec.add_dependency('addressable', '~> 2')
  spec.add_dependency('activesupport', '>= 4.2.2')
  spec.add_development_dependency "manageiq-style"
  spec.add_development_dependency "rspec",         '~> 3'

  spec.description = <<-EOF
    The azure-signature library generates storage signatures for
    Microsoft Azure's cloud platform. You can use this to access
    Azure storage services - tables, blobs, queues and files.
  EOF

  spec.metadata = {
    'homepage_uri'      => 'https://github.com/ManageIQ/azure-signature',
    'bug_tracker_uri'   => 'https://github.com/ManageIQ/azure-signature/issues',
    'changelog_uri'     => 'https://github.com/ManageIQ/azure-signature/blob/master/CHANGELOG.md',
    'documentation_uri' => 'https://github.com/ManageIQ/azure-signature/wiki',
    'source_code_uri'   => 'https://github.com/ManageIQ/azure-signature',
    'wiki_uri'          => 'https://github.com/ManageIQ/azure-signature/wiki'
  }
end
