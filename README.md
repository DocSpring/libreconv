# Libreconv

Convert office documents to PDF using LibreOffice / OpenOffice.

[![Code Climate](https://codeclimate.com/github/ricn/libreconv.png)](https://codeclimate.com/github/ricn/libreconv)

## Installation

Add this line to your application's Gemfile:

    gem 'libreconv'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install libreconv

## Usage

You need to install Libreoffice or Openoffice on your system to use this gem. The code has been tested with Libreoffice 4.0.

```ruby
require 'libreconv'

# Converts document.docx to document.pdf
# This requires that the soffice binary is present in your PATH.
Libreconv.convert('document.docx', '/Users/ricn/pdf_documents')

# You can also convert a source file directly from an URL
Libreconv.convert('http://myserver.com/123/document.docx', '/Users/ricn/pdf_documents')

# Converts document.docx to document.pdf
# If you for some reason can't have soffice in your PATH you can specifiy the file path to the soffice binary
Libreconv.convert('document.docx', '/Users/ricn/pdf_documents', '/Applications/LibreOffice.app/Contents/MacOS/soffice')

```

## Credits

The following people have contributed ideas, documentation, or code to Libreconv:

* Richard Nyström

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
