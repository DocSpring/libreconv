# encoding: utf-8

require 'spec_helper'
 
describe Libreconv do 
  
  before(:all) do
    @docx_file = file_path("document.docx")
    @doc_file = file_path("document.doc")
  end

  after(:all) do
  end

  describe '.convert' do
    it "should raise error if soffice command does not exists" do
      lambda { Libreconv.convert(@doc_file, "/Whatever/soffice") }.should raise_error(IOError)
    end

    it "should raise error if source file does not exists" do
      lambda { Libreconv.convert(file_path("nonsense.txt")) }.should raise_error(IOError)
    end
  end
end
