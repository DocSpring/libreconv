# frozen_string_literal: true

require 'libreconv/version'
require 'uri'
require 'net/http'
require 'tmpdir'
require 'securerandom'
require 'open3'

module Libreconv
  class ConversionFailedError < StandardError; end

  SOURCE_TYPES = {
    file: 1,
    url: 2
  }.freeze

  def self.convert(source, target, soffice_command = nil, convert_to = nil)
    Converter.new(source, target, soffice_command, convert_to).convert
  end

  class Converter
    attr_accessor :soffice_command

    def initialize(source, target, soffice_command = nil, convert_to = nil)
      @source = source
      @target = target
      @soffice_command =
        soffice_command ||
        which('soffice') ||
        which('soffice.bin')
      @convert_to = convert_to || 'pdf'
      @source_type = check_source_type

      # If the URL contains GET params, the '&' could break when
      # being used as an argument to soffice. Wrap it in single
      # quotes to escape it. Then strip them from the target
      # temp file name.
      @escaped_source =
        if @source_type == 1
          @source
        else
          "'#{@source}'"
        end
      @escaped_source_path =
        if @source_type == 1
          @source
        else
          URI.parse(@source).path
        end

      ensure_soffice_exists
    end

    def convert
      pipe_uuid = SecureRandom.uuid

      Dir.mktmpdir do |target_path|
        accept_args = [
          "pipe,name=soffice-pipe-#{pipe_uuid}",
          'url',
          'StarOffice.ServiceManager'
        ].join(';')

        command = [
          soffice_command,
          "--accept=\"#{accept_args}\"",
          "-env:UserInstallation=file:///tmp/soffice-dir-#{pipe_uuid}",
          '--headless',
          '--convert-to',
          @convert_to,
          @escaped_source,
          '--outdir',
          target_path
        ]

        output, error, status = Open3.capture3(
          {
            'HOME' => ENV['HOME'],
            'PATH' => ENV['PATH'],
            'LANG' => ENV['LANG']
          },
          *command,
          unsetenv_others: true
        )
        unless status.success? && error == ''
          raise ConversionFailedError,
                "Conversion failed! Output: #{output.strip.inspect}, " \
                "Error: #{error.strip.inspect}"
        end

        target_tmp_file = "#{target_path}/" \
          "#{File.basename(@escaped_source_path, '.*')}." \
          "#{File.basename(@convert_to, ':*')}"
        FileUtils.cp target_tmp_file, @target
        FileUtils.rm_rf("/tmp/soffice-dir-#{pipe_uuid}")
      end
    end

    private

    def ensure_soffice_exists
      return if soffice_command && File.exist?(soffice_command)

      raise IOError, "Can't find Libreoffice or Openoffice executable."
    end

    def which(cmd)
      exts = ENV['PATHEXT'] ? ENV['PATHEXT'].split(';') : ['']
      ENV['PATH'].split(File::PATH_SEPARATOR).each do |path|
        exts.each do |ext|
          exe = File.join(path, "#{cmd}#{ext}")
          return exe if File.executable? exe
        end
      end

      nil
    end

    def check_source_type
      if File.exist?(@source) && !File.directory?(@source)
        return SOURCE_TYPES[:file]
      end
      if URI(@source).scheme == 'http' &&
         Net::HTTP.get_response(URI(@source)).is_a?(Net::HTTPSuccess)
        return SOURCE_TYPES[:url]
      end
      if URI(@source).scheme == 'https' &&
         Net::HTTP.get_response(URI(@source)).is_a?(Net::HTTPSuccess)
        return SOURCE_TYPES[:url]
      end

      raise IOError, "Source (#{@source}) is neither a file nor a URL."
    end
  end
end
