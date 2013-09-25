module Mitm
  module Backend
    def default
      require 'backend/redis'
      Mitm::Backend::Redis.new("127.0.0.1", 6379)
    end
  end
end