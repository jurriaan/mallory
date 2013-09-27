require 'redis'

module Mallory
  module Backend
    class Redis

      def initialize(host, port)
        redis = ::Redis.new(:host => host, :port => port)
        @proxies = redis.smembers("good_proxies")
      end

      def any
        @proxies.sample
      end

    end
  end
end
