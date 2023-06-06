# frozen_string_literal: true

RSpec.describe Libreconv::Converter do
  describe '#convert' do
    it 'raises error when URL cannot be loaded' do
      stub_request(:head, url = 'http://s3.amazonaws.com/libreconv-test/docx.docx')

      # Error: source file could not be loaded
      expect do
        described_class.new(url, '/target').convert
      end.to raise_error(Libreconv::ConversionFailedError, /\bConversion failed\b/i)
    end

    it 'converts a source URL to pdf' do
      url = stub_sample_url

      create_tmpfile(['', '.pdf']) do |target_file|
        described_class.new(url, target_file).convert

        expect(File.size?(target_file)).to be > 0
      end
    end
  end

  def stub_sample_url
    url = 'http://file-examples.com/wp-content/storage/2017/02/file-sample_100kB.doc'
    redirection = url.sub(/^http:/i, 'https:') + '?a=a&b=b#c'

    stub_request(:head, url)
      .to_return(status: [301, 302, 307, 308].sample, headers: { location: redirection })
    stub_request(:head, redirection.sub(/\?.*?$/, ''))
      .with(query: hash_including('a' => 'a', 'b' => 'b'))

    url
  end
end
