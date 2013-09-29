module Mallory
  class RequestBuilder
    def initialize(config)
      @config = config
    end

    def build(data)
      Mallory::Request.new(data, @config.logger)
    end
  end
end
