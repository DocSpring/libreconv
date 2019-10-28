# frozen_string_literal: true

require 'libreconv/version'
require 'uri'
require 'net/http'
require 'tmpdir'
require 'securerandom'
require 'open3'

# Convert office documents using LibreOffice / OpenOffice to one of their supported formats.
module Libreconv
  class ConversionFailedError < StandardError; end

  # @param [String] source          Path or URL of the source file.
  # @param [String] target          Target file path.
  # @param [String] soffice_command Path to the soffice binary.
  # @param [String] convert_to      Format to convert to (default: 'pdf').
  # @raise [IOError]                If invalid source file/URL or soffice command not found.
  # @raise [URI::Error]             When URI parsing error.
  # @raise [Net::ProtocolError]     If source URL checking failed.
  # @raise [ConversionFailedError]  When soffice command execution error.
  def self.convert(source, target, soffice_command = nil, convert_to = nil)
    Converter.new(source, target, soffice_command, convert_to).convert
  end

  class Converter
    # @return [String]
    attr_accessor :soffice_command

    # @param [String] source          Path or URL of the source file.
    # @param [String] target          Target file path.
    # @param [String] soffice_command Path to the soffice binary.
    # @param [String] convert_to      Format to convert to (default: 'pdf').
    # @raise [IOError]                If invalid source file/URL or soffice command not found.
    # @raise [URI::Error]             When URI parsing error.
    # @raise [Net::ProtocolError]     If source URL checking failed.
    def initialize(source, target, soffice_command = nil, convert_to = nil)
      @source = check_source_type(source)
      @target = target
      @soffice_command = soffice_command || which('soffice') || which('soffice.bin')
      @convert_to = convert_to || 'pdf'

      ensure_soffice_exists
    end

    # @raise [ConversionFailedError]  When soffice command execution error.
    def convert
      tmp_pipe_path = File.join(Dir.tmpdir, "soffice-pipe-#{SecureRandom.uuid}")

      Dir.mktmpdir do |target_path|
        command = build_command(tmp_pipe_path, target_path)
        target_tmp_file = execute_command(command, target_path)

        FileUtils.cp target_tmp_file, @target
      end
    ensure
      FileUtils.rm_rf tmp_pipe_path if File.exist?(tmp_pipe_path)
    end

    private

    # @param [Array<String>] command
    # @param [String] target_path
    # @return [String]
    # @raise [ConversionFailedError]  When soffice command execution error.
    def execute_command(command, target_path)
      output, error, status =
        if RUBY_PLATFORM =~ /java/
          Open3.capture3(*command)
        else
          Open3.capture3(command_env, *command, unsetenv_others: true)
        end

      target_tmp_file = File.join(target_path, target_filename)
      return target_tmp_file if status.success? && File.exist?(target_tmp_file)

      raise ConversionFailedError,
            "Conversion failed! Output: #{output.strip.inspect}, Error: #{error.strip.inspect}"
    end

    # @return [Hash]
    def command_env
      Hash[%w[HOME PATH LANG LD_LIBRARY_PATH SYSTEMROOT TEMP].map { |k| [k, ENV[k]] }]
    end

    # @param [String] tmp_pipe_path
    # @param [String] target_path
    # @return [Array<String>]
    def build_command(tmp_pipe_path, target_path)
      [
        soffice_command,
        "--accept=\"pipe,name=#{File.basename(tmp_pipe_path)};url;StarOffice.ServiceManager\"",
        "-env:UserInstallation=#{build_file_uri(tmp_pipe_path)}",
        '--headless',
        '--convert-to', @convert_to,
        escaped_source,
        '--outdir', target_path
      ]
    end

    # If the URL contains GET params, the '&' could break when being used as an argument to soffice.
    # Wrap it in single quotes to escape it. Then strip them from the target temp file name.
    # @return [String]
    def escaped_source
      # TODO: @source.is_a?(URI::Generic) ? "'#{@source}'" : @source
      @source.to_s
    end

    # @return [String]
    def escaped_source_path
      @source.is_a?(URI::Generic) ? @source.path : @source
    end

    # @return [String]
    def target_filename
      File.basename(escaped_source_path, '.*') + '.' + File.basename(@convert_to, ':*')
    end

    # @raise [IOError] If soffice headless command line tool not found.
    def ensure_soffice_exists
      return if soffice_command && File.exist?(soffice_command)

      raise IOError, 'Can\'t find LibreOffice or OpenOffice executable.'
    end

    # @param [String] cmd
    # @return [String, nil]
    def which(cmd)
      exts = ENV['PATHEXT'] ? ENV['PATHEXT'].split(';') : ['']

      ENV['PATH'].split(File::PATH_SEPARATOR).each do |path|
        exts.each do |ext|
          exe = File.expand_path("#{cmd}#{ext}", path)
          return exe if File.executable? exe
        end
      end

      nil
    end

    # @param [String] source
    # @return [String, URI::HTTP]
    # @raise [IOError]            If invalid source file/URL.
    # @raise [URI::Error]         When URI parsing error.
    # @raise [Net::ProtocolError] If source URL checking failed.
    def check_source_type(source)
      if File.exist?(source)
        return source unless File.directory?(source)
      elsif (uri = check_valid_url(source))
        return uri
      end

      raise IOError, "Source (#{source}) is neither a file nor a URL."
    end

    # @param [String] url
    # @return [URI::HTTP, false, nil]
    # @raise [URI::Error]         When URI parsing error.
    # @raise [Net::ProtocolError] If source URL checking failed.
    def check_valid_url(url)
      uri = URI(url)
      return false unless uri.is_a?(URI::HTTP)

      Net::HTTP.start(uri.hostname, uri.port, use_ssl: uri.scheme == 'https') do |http|
        response = http.head(uri.request_uri)
        return check_valid_url(response['location']) if response.is_a?(Net::HTTPRedirection)

        return response.is_a?(Net::HTTPSuccess) ? uri : nil
      end
    end

    # @param [String] path
    # @return [String]
    def build_file_uri(path)
      separators = /[#{Regexp.quote "#{File::SEPARATOR}#{File::ALT_SEPARATOR}"}]/
      unsafe = Regexp.new("[^#{URI::PATTERN::UNRESERVED}/?:]")

      'file:///' + URI::DEFAULT_PARSER.escape(path.gsub(separators, '/').sub(%r{^/+}, ''), unsafe)
    end
  end
end
