# frozen_string_literal: true

require 'spec_helper'

describe Libreconv do
  let(:docx_file) { fixture_path('docx.docx') }
  let(:doc_file) { fixture_path('doc.doc') }
  let(:pptx_file) { fixture_path('pptx.pptx') }
  let(:ppt_file) { fixture_path('ppt.ppt') }
  let(:target_path) { '/tmp/libreconv' }
  let(:url) { 'http://s3.amazonaws.com/libreconv-test/docx.docx' }

  before do
    FileUtils.mkdir_p target_path
  end

  after do
    FileUtils.rm_rf target_path
  end

  describe Libreconv::Converter do
    describe '#new' do
      it 'raises error if soffice command does not exists' do
        expect do
          described_class.new(
            doc_file, '/target', '/Whatever/soffice'
          )
        end.to raise_error(IOError)
      end

      it 'raises error if source does not exists' do
        expect do
          described_class.new(
            fixture_path('nonsense.txt'), '/target'
          )
        end.to raise_error(IOError)
      end
    end

    describe '#convert' do
      it 'converts a docx do pdf specifying target_file' do
        target_file = "#{target_path}/#{File.basename(doc_file, '.doc')}.pdf"
        converter = described_class.new(doc_file, target_file)
        converter.convert
        expect(File.file?(target_file)).to eq true
      end

      it 'converts a doc to pdf' do
        target_file = "#{target_path}/#{File.basename(doc_file, '.doc')}.pdf"
        converter = described_class.new(doc_file, target_path)
        converter.convert
        expect(File.file?(target_file)).to eq true
      end

      it 'converts a docx to pdf' do
        target_file = "#{target_path}/#{File.basename(docx_file, '.docx')}.pdf"
        converter = described_class.new(docx_file, target_path)
        converter.convert
        expect(File.file?(target_file)).to eq true
      end

      it 'converts a pptx to pdf' do
        target_file = "#{target_path}/#{File.basename(pptx_file, '.pptx')}.pdf"
        converter = described_class.new(pptx_file, target_path)
        converter.convert
        expect(File.file?(target_file)).to eq true
      end

      it 'converts a ppt to pdf' do
        target_file = "#{target_path}/#{File.basename(ppt_file, '.ppt')}.pdf"
        converter = described_class.new(ppt_file, target_path)
        converter.convert
        expect(File.file?(target_file)).to eq true
      end

      # it 'raises ConversionFailedError when URL cannot be loaded' do
      #   stub_request(:get, url)
      #   expect do
      #     converter = described_class.new(url, target_path)
      #     converter.convert
      #   end.to raise_error(
      #     Libreconv::ConversionFailedError,
      #     /Conversion failed/
      #   )
      # end
    end

    describe '#soffice_command' do
      it 'returns the user specified command path' do
        # Just faking that the command is present here
        cmd = fixture_path('soffice')
        converter = described_class.new(doc_file, '/target', cmd)
        expect(converter.soffice_command).to eq cmd
      end

      it 'returns the command found in path' do
        cmd = `which soffice`.strip
        converter = described_class.new(doc_file, '/target')
        expect(converter.soffice_command).to eq cmd
      end
    end
  end

  describe '#convert' do
    it 'converts a file to pdf' do
      target_file = "#{target_path}/#{File.basename(doc_file, '.doc')}.pdf"
      described_class.convert(doc_file, target_path)
      expect(File.file?(target_file)).to eq true
    end
  end
end
