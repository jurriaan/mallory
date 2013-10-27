module Mallory
  module SSL
    class CertificateManager

      def initialize storage, factory
        @storage = storage
        @factory = factory
      end

      def get domain
        key = @storage.get(domain)
        if not key.nil?
          return key
        end
        key = @factory.get(domain)
        @storage.put(key)
        return key
      end

    end
  end
end
