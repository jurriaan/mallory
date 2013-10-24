module Mallory
  module Backend
    class Self
      def initialize()
        @proxies = []
      end

      def any
        @proxies.sample
      end

      def all
        @proxies
      end

    end
  end
end
