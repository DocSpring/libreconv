# frozen_string_literal: true

require 'libreconv'
require 'pry-byebug'
require 'webmock/rspec'

def fixture_path(*paths)
  File.expand_path(File.join(File.dirname(__FILE__), 'fixtures', *paths))
end

RSpec.configure do |config|
  config.run_all_when_everything_filtered = true
  config.filter_run :focus

  config.order = 'random'
end
