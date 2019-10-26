# frozen_string_literal: true

RSpec.describe Libreconv do
  it 'has a version number' do
    expect(Libreconv::VERSION).to be_truthy
  end

  describe '.convert' do
    it 'converts an office file to the specified target pdf' do
      create_tmpfile(['', '.pdf']) do |target_file|
        described_class.convert(fixture_file, target_file)

        expect(File.size?(target_file)).to be > 0
      end
    end
  end
end
