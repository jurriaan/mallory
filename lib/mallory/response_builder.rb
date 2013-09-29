module EventMachine
  class Mallory::ResponseBuilder
    def initialize(config)
      @config = config
    end

    def build(data)
      Mallory::Response.new(data, @config.logger)
    end
  end
end
