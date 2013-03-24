require "libreconv/version"

module Libreconv

  def self.convert(source, soffice_command = nil)
    
    unless soffice_present?(soffice_command) 
      raise IOError, "Can't find Libreoffice or Openoffice executable."
    end

    unless File.exists?(source)
      raise IOError, "Source file (#{@source}) does not exist."
    end
  end

  def self.which(cmd)
    exts = ENV['PATHEXT'] ? ENV['PATHEXT'].split(';') : ['']
    ENV['PATH'].split(File::PATH_SEPARATOR).each do |path|
      exts.each { |ext|
        exe = File.join(path, "#{cmd}#{ext}")
        return exe if File.executable? exe
      }
    end
    
    return nil
  end

  private

  def self.soffice_present?(soffice_command = nil)
    if soffice_command
      File.exists?(soffice_command)
    else
      self.which("soffice.exe") || self.which("soffice.bin") || self.which("soffice")
    end
  end
end
