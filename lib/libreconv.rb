require "libreconv/version"

module Libreconv

  def self.convert(source, target, soffice_command = nil)
    Converter.new(source, target, soffice_command)
  end

  class Converter
    attr_accessor :soffice_command

    def initialize(source, target_path, soffice_command = nil)
      @source = source
      @target_path = target_path
      @soffice_command = soffice_command 
      determine_soffice_command
      
      unless @soffice_command && File.exists?(@soffice_command) 
        raise IOError, "Can't find Libreoffice or Openoffice executable."
      end

      unless File.exists?(source)
        raise IOError, "Source file (#{source}) does not exist."
      end
    end

    def convert
      system("#{@soffice_command} --headless --convert-to pdf #{@source} -outdir #{@target_path}")
    end

    private

    def determine_soffice_command
      unless @soffice_command
        @soffice_command ||= which("soffice")
        @soffice_command ||= which("soffice.bin")
        @soffice_command ||= which("soffice.exe")
      end
    end

    def which(cmd)
      exts = ENV['PATHEXT'] ? ENV['PATHEXT'].split(';') : ['']
      ENV['PATH'].split(File::PATH_SEPARATOR).each do |path|
        exts.each do |ext|
          exe = File.join(path, "#{cmd}#{ext}")
          return exe if File.executable? exe
        end
      end
    
      return nil
    end
  end
end