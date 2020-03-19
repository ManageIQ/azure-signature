## Description

A Ruby library for generating an authentication signature for Azure storage services.

## Installation

`gem install azure-signature`

## Synopis

  ```ruby
  require 'azure/signature'

  key = "SGVsbG8gV29ybGQ="
  url = "http://testsnapshots.blob.core.windows.net/Tables"

  sig = Azure::Signature.new(url, key)

  # Look at canonical URL
  p sig.canonical_url # => "/testsnapshots/Tables"

  # Get a signature with the defaults
  p sig.signature(:table)

  # Or pass some options
  p sig.signature(:table, :auth_string => true, :date => some_date, :verb => 'PUT')
  ```

## Acknowledgements

I borrowed the code to canonicalize resources and headers from the
azure-sdk-for-ruby project.

## License

Apache-2.0

http://www.apache.org/licenses/LICENSE-2.0

## Warranty

This package is provided "as is" and without any express or
implied warranties, including, without limitation, the implied
warranties of merchantability and fitness for a particular purpose.

## Author

Daniel Berger
