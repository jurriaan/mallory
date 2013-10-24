module Mallory
  class Configuration
    # defining instance variable at class level
    # this will ensure that static config is
    # not shared with objects created by calling
    # Configuration.new
    @settings = {}

    def self.register
      if block_given?
        yield(self)
      end
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

    def self.certificate_authority
      @settings[:certificate_authority]
    end

    def self.certificate_authority=(other)
      @settings[:certificate_authority] = other
    end

    def self.listen
      @settings[:listen]
    end

    def self.listen=(other)
      @settings[:listen] = other
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
