# frozen_string_literal: true

RSpec.describe Libreconv::Converter do
  describe '#convert' do
    it 'converts a file to the specified target html' do
      create_tmpfile(['', '.html']) do |target_file|
        described_class.new(fixture_file, target_file, nil, 'html').convert

        expect(File.size?(target_file)).to be > 0
      end
    end

    it 'converts a file to the specified target html with EmbedImages options' do
      create_tmpfile(['', '.html']) do |target_file|
        fixture_file = fixture_path('docx_with_image.docx')
        described_class.new(fixture_file, target_file, nil, 'html:HTML:EmbedImages').convert

        converted_file = File.read(target_file)
        expect(File.size?(target_file)).to be > 0
        expect(converted_file).to include('data:image/png;base64')
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
