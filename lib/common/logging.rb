require 'logger'
require 'fileutils'

module Common
  module Logging

    def set_logging_level level
      logger.level = level
    end

    def logger
      Logging.logger
    end

    def self.logger
      @logger ||= begin
        create_log_file
        logger = Logger.new(full_log_file_path)
        logger.level = Logger::DEBUG
        logger.formatter = Logger::Formatter.new
        logger
      end
    end

    def log_error(message, error)
      logger.error "#{message}. #{error.class} - #{error.message} #{error.backtrace.join("\n")}"
    end

    def self.create_log_file
      FileUtils.mkdir_p('logs')
      FileUtils.touch(full_log_file_path)
    end

    private

    def self.log_file_name
      'app.log'
    end

    def self.full_log_file_path
      "logs/#{log_file_name}"
    end
  end
end
