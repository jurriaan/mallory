module Mallory
  class Configuration
    # defining instance variable at class level
    # this will ensure that static config is
    # not shared with objects created by calling
    # Configuration.new
    @settings = {}

    def self.register
      yield(self) if block_given?
      self
    end

    def self.logger
      @settings[:logger]
    end

    def self.logger=(other)
      @settings[:logger] = other
    end

    def self.backend
      @settings[:backend]
    end

    def self.backend=(other)
      @settings[:backend] = other
    end

    def self.certificate_manager
      @settings[:certificate_manager]
    end

    def self.certificate_manager=(other)
      @settings[:certificate_manager] = other
    end

    def self.port
      @settings[:port]
    end

    def self.port=(other)
      @settings[:port] = other
    end

    def self.connect_timeout
      @settings[:connect_timeout]
    end

    def self.connect_timeout=(other)
      @settings[:connect_timeout] = other
    end

    def self.inactivity_timeout
      @settings[:inactivity_timeout]
    end

    def self.inactivity_timeout=(other)
      @settings[:inactivity_timeout] = other
    end

    def self.reset!
      @settings = {}
    end
  end
end
