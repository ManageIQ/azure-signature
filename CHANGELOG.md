# Change Log

All notable changes to this project will be documented in this file.

= 0.2.3 - 19-Jul-2016
* Removed the cgi dependency.

= 0.2.2 - 17-Jun-2016
* The resource argument to the constructor is now automatically escaped.

= 0.2.1 - 13-Jun-2016
* The signature methods now accept standard header strings as key arguments
  as well as symbols, e.g. 'auth-type' vs :auth_type.
* Replaced URI with Addressable::URI since it's more robust.

= 0.2.0 - 13-Oct-2015
* Added support for other types of signatures (blobs, queues, files).
* The :auth_string argument no longer returns the word "Authorization".
* Added an azure-signature file for convenience.

= 0.1.0 - 25-Sep-2015
* Initial release
