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
      lambda { Libreconv.convert(@doc_file, "/target", "/Whatever/soffice") }.should raise_error(IOError)
    end

    it "should raise error if source file does not exists" do
      source = file_path("nonsense.txt")
      lambda { Libreconv.convert(source, "/target") }.should raise_error(IOError)
    end

    it "should convert a doc to pdf" do
      source = @doc_file
      target = "/Users/ricn/temp"
      Libreconv.convert(source, target)
      File.exists?(target).should == true
    end
  end
end
