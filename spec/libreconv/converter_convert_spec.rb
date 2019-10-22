# frozen_string_literal: true

RSpec.describe Libreconv::Converter do
  describe '#convert' do
    it 'converts a file to the specified target html' do
      create_tmpfile(suffix: '.html') do |target_file|
        described_class.new(fixture_file, target_file, nil, 'html').convert

        expect(File.size?(target_file)).to be > 0
      end
    end

    Helpers::FILE_TYPES.each do |type|
      it "converts a #{type} to pdf" do
        Dir.mktmpdir do |target_path|
          described_class.new(source = fixture_file(type), target_path).convert

          target_file = File.join target_path, "#{File.basename(source, '.*')}.pdf"
          expect(File.size?(target_file)).to be > 0
        end
      end
    end
  end
end
