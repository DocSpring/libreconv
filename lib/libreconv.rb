require "libreconv/version"
require "uri"
require "net/http"
require "tmpdir"
require "spoon"

module Libreconv

  def self.convert(source, target, soffice_command = nil, convert_to = nil)
    Converter.new(source, target, soffice_command, convert_to).convert
  end

  class Converter
    attr_accessor :soffice_command

    def initialize(source, target, soffice_command = nil, convert_to = nil)
      @source = source
      @target = target
      @soffice_command = soffice_command
      @convert_to = convert_to || "pdf"
      determine_soffice_command
      @source_type = check_source_type

      # If the URL contains GET params, the '&' could break when being used
      # as an argument to soffice. Wrap it in single quotes to escape it.
      # Then strip them from the target temp file name
      @escaped_source = @source_type == 1 ? @source : "'#{@source}'"
      @escaped_source_path = @source_type == 1 ? @source : URI.parse(@source).path

      unless @soffice_command && File.exists?(@soffice_command)
        raise IOError, "Can't find Libreoffice or Openoffice executable."
      end
    end

    def convert
      Dir.mktmpdir { |target_path|
        orig_stdout = $stdout.clone
        $stdout.reopen File.new('/dev/null', 'w')
        pid = Spoon.spawnp(@soffice_command, "--headless", "--convert-to", @convert_to, @escaped_source, "--outdir", target_path)
        Process.waitpid(pid)
        $stdout.reopen orig_stdout
        target_tmp_file = "#{target_path}/#{File.basename(@escaped_source_path, ".*")}.#{File.basename(@convert_to, ":*")}"
        FileUtils.cp target_tmp_file, @target
      }
    end

    private

    def determine_soffice_command
      unless @soffice_command
        @soffice_command ||= which("soffice")
        @soffice_command ||= which("soffice.bin")
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

    def check_source_type
      return 1 if File.exists?(@source) && !File.directory?(@source) #file
      return 2 if URI(@source).scheme == "http" && Net::HTTP.get_response(URI(@source)).is_a?(Net::HTTPSuccess) #http
      return 2 if URI(@source).scheme == "https" && Net::HTTP.get_response(URI(@source)).is_a?(Net::HTTPSuccess) #https
      raise IOError, "Source (#{@source}) is neither a file nor an URL."
    end
  end
end
