# frozen_string_literal: true

RSpec.describe Libreconv::Converter do
  let :converter do
    described_class.new fixture_file, '/target', fixture_path('soffice')
  end

  describe '#build_file_uri' do
    it 'converts a file path to file URI' do
      url = converter.send(:build_file_uri, File.join(Dir.tmpdir, 'soffice-pipe'))
      expect(url).to start_with('file:///').and end_with('/soffice-pipe')
    end

    it 'builds file URI from a path with special characters' do
      s = File::ALT_SEPARATOR || File::SEPARATOR
      url = converter.send(:build_file_uri, "C:#{s}User\"s#{s}a'中 Я#{s}Temp&/soffice=pipe")

      expect(url).to eq 'file:///C:/User%22s/a\'%E4%B8%AD%20%D0%AF/Temp%26/soffice%3Dpipe'
    end
  end
end
