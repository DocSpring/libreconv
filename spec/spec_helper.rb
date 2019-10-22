# frozen_string_literal: true

require 'bundler/setup'
require 'libreconv'

require 'webmock/rspec'

module Helpers
  FILE_TYPES = %i[docx doc pptx ppt xlsx xls].freeze

  # @return [String]
  def fixture_path(*paths)
    File.expand_path(File.join('fixtures', *paths), __dir__)
  end

  # @return [String]
  def fixture_file(type = nil)
    type = FILE_TYPES.sample unless type && FILE_TYPES.include?(type)
    fixture_path "#{type}.#{type}"
  end

  # @yieldreturn [String]
  def create_tmpfile(prefix: '', suffix: '', tmpdir: nil)
    Dir::Tmpname.create([prefix, suffix], tmpdir) do |tmpfile|
      begin
        yield tmpfile
      ensure
        File.unlink tmpfile if File.exist?(tmpfile)
      end
    end
  end
end

RSpec.configure do |config|
  # Zero monkey patching mode
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.filter_run_when_matching :focus
  config.include Helpers
end
