module EventMachine
  class Mallory::ProxyBuilder
    def initialize(config, response_builder)
      @config = config
      @response_builder = response_builder
    end

    def build
      Mallory::Proxy.new(@config.connect_timeout, @config.inactivity_timeout, @config.backend, @response_builder, @config.logger)
    end
  end
end
