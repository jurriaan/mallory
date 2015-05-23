class Mallory::ProxyBuilder
  def initialize(config, response_builder)
    @config = config
    @response_builder = response_builder
  end

  def build
    Mallory::Proxy.new(@config.connect_timeout, @config.inactivity_timeout, @response_builder, @config.logger, @config.certificate_manager)
  end
end
