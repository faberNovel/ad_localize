module AdLocalize
  class AdLogger
    def initialize
      @logger = Logger.new(STDOUT)
      @logger.level = Logger::INFO
    end

    def warn(text)
      log(level: Logger::WARN, text: text.yellow)
    end

    def info(text)
      log(level: Logger::INFO, text: text.blue)
    end

    def error(text)
      log(level: Logger::ERROR, text: text.red)
    end

    def debug(text)
      log(level: Logger::DEBUG, text: text.black)
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

    private

    def log(level:, text:)
      @logger.add(level, text)
    end
  end
end
