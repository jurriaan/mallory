module Mallory
  module SSL
    class CertificateManager
      def initialize(storage, factory)
        @storage = storage
        @factory = factory
      end

      def get(domain)
        key = @storage.get(domain)
        return key unless key.nil?
        key = @factory.get(domain)
        @storage.put(key)
        key
      end
    end
  end
end
