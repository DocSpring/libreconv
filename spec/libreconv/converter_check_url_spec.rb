# frozen_string_literal: true

RSpec.describe Libreconv::Converter do
  let(:converter) { described_class.new fixture_file, '/', fixture_path('soffice') }

  describe '#check_valid_url' do
    it 'returns false for non-HTTP url' do
      expect(converter.send(:check_valid_url, 'ftp://test.com/')).to eq false
    end

    it 'raises error for invalid URI' do
      expect { converter.send(:check_valid_url, '~://test.com/') }.to raise_error(URI::Error)
    end

    it 'returns NIL for non-exists url' do
      stub_request(:head, url = 'http://test.com/').to_return(status: [404, 500].sample)
      expect(converter.send(:check_valid_url, url)).to be_nil
    end

    it 'raises HTTP error when requesting failed' do
      stub_request(:head, url = 'https://test.com/').to_timeout
      expect { converter.send(:check_valid_url, url) }.to raise_error(Timeout::Error)
    end

    it 'returns URI for valid url' do
      redirect = (url = 'http://test.com/').sub(/^http:/i, 'https:') + '?l[]=1&l[]=2#t'
      stub_request(:head, url).to_return(status: 301, headers: { location: redirect })
      stub_request(:head, redirect.sub(/\?.*?$/, '')).with(query: hash_including('l' => %w[1 2]))

      uri = converter.send(:check_valid_url, url)
      expect(uri).to be_kind_of(URI::HTTPS).and have_attributes(query: 'l[]=1&l[]=2')
    end
  end
end
