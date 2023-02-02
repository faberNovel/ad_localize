# frozen_string_literal: true
module AdLocalize
  class AdLogger
    def initialize
      @logger = Logger.new(STDOUT)
      @logger.level = Logger::INFO
    end

    def warn(text)
      @logger.warn(text.yellow)
    end

    def info(text)
      @logger.info(text.blue)
    end

    def error(text)
      @logger.error(text.red)
    end

    def debug(text)
      @logger.debug(text)
    end

    def info!
      @logger.level = Logger::INFO
    end

    def debug!
      @logger.level = Logger::DEBUG
    end

    def debug?
      @logger.debug?
    end

    def close
      @logger.close
    end
  end
end
