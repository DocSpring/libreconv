# encoding: utf-8

require 'spec_helper'
 
describe Libreconv do 
  
  before(:all) do
    @docx_file = file_path("docx.docx")
    @doc_file = file_path("doc.doc")
    @pptx_file = file_path("pptx.pptx")
    @ppt_file = file_path("ppt.ppt")
    @bin_file = file_path("bin.bin")
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
        target_path = "/tmp"
        target_file = "#{target_path}/#{File.basename(source, ".doc")}.pdf" 
        converter = Libreconv::Converter.new(source, target_path)
        converter.convert
        File.exists?(target_file).should == true
      end

      it "should convert a docx to pdf" do
        source = @docx_file
        target_path = "/tmp"
        target_file = "#{target_path}/#{File.basename(source, ".docx")}.pdf" 
        converter = Libreconv::Converter.new(source, target_path)
        converter.convert
        File.exists?(target_file).should == true
      end

      it "should convert a pptx to pdf" do
        source = @pptx_file
        target_path = "/tmp"
        target_file = "#{target_path}/#{File.basename(source, ".pptx")}.pdf" 
        converter = Libreconv::Converter.new(source, target_path)
        converter.convert
        File.exists?(target_file).should == true
      end

      it "should convert a ppt to pdf" do
        source = @ppt_file
        target_path = "/tmp"
        target_file = "#{target_path}/#{File.basename(source, ".ppt")}.pdf" 
        converter = Libreconv::Converter.new(source, target_path)
        converter.convert
        File.exists?(target_file).should == true
      end

      it "try converting binary file" do
        source = @bin_file
        target_path = "/tmp"
        target_file = "#{target_path}/#{File.basename(source, ".bin")}.pdf" 
        converter = Libreconv::Converter.new(source, target_path)
        converter.convert
        File.exists?(target_file).should == false
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