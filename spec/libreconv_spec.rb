# encoding: utf-8

require 'spec_helper'
 
describe Libreconv do 
  
  before(:all) do
    @docx_parser = Rika::Parser.new(file_path("document.docx"))
  end

  after(:all) do
  end

  describe '.convert' do
    it "should raise error if soffice or soffice.bin command does not exists" do
      lambda { Libreconv.convert(file_path("nonsense.txt")) }.should raise_error(IOError)
    end

    it "should raise error if source file does not exists" do
      pending
    end
    
  end
end
