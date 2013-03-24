# encoding: utf-8

require 'spec_helper'
 
describe Libreconv do 
  
  before(:all) do
    @docx_file = file_path("document.docx")
    @doc_file = file_path("document.doc")
  end

  after(:all) do
  end

  describe Libreconv::Converter do
    describe "#new" do
      it "should raise error if soffice command does not exists" do
        lambda { Libreconv::Converter.new(@doc_file, "/target", "/Whatever/soffice") }.should raise_error(IOError)
      end

      it "should raise error if source file does not exists" do
        lambda { Libreconv::Converter.new(file_path("nonsense.txt"), "/target") }.should raise_error(IOError)
      end
    end

    describe "#convert" do
      it "should convert a doc to pdf" do
        source = @doc_file
        target_path = "/Users/ricn/temp"
        target_file = "#{target_path}/#{File.basename(@doc_file, ".doc")}.pdf" 
        Libreconv::Converter.new(source, target_path)
        File.exists?(target_file).should == true
      end
    end

    describe "#soffice_command" do
      it "should return the user specified command path" do
        cmd = file_path("soffice") # just faking that the command is present here
        converter = Libreconv::Converter.new(@doc_file, "/target", cmd)
        converter.soffice_command.should == cmd
      end

      it "should return the command found in path" do
        cmd = `which soffice`.strip
        converter = Libreconv::Converter.new(@doc_file, "/target")
        converter.soffice_command.should == cmd
      end
    end
  end
end
