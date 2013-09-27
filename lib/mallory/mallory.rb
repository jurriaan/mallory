require 'eventmachine'

$stdout.sync = true

Signal.trap("INT")  { puts "Gracefully exiting"; EventMachine.stop }
Signal.trap("TERM") { puts "Gracefully exiting"; EventMachine.stop }

EM.kqueue if EM.kqueue? #osx
EM.epoll  if EM.epoll? #linux

module EventMachine
  module Mallory
    class Server
      def initialize options
        @listen = options.delete(:listen) || 9999
        @connect_timeout = options.delete(:connect_timeout) || 2
        @inactivity_timeout = options.delete(:inactivity_timeout) || 2
        @backend = EventMachine::Mallory::Backend::File.new("#{Dir.pwd}/proxies.txt")

        verbose = options.delete(:verbose) || false
        @logger = EventMachine::Mallory::Logger.instance
        @logger.verbose = true if verbose
      end

      def backend backend
        @backend = Mallory::Backend::Redis.new("127.0.0.1", 6379)
      end

      def start!
        EventMachine.run {
          @logger.info "Starting mallory"
          EventMachine.start_server '127.0.0.1', @listen, EventMachine::Mallory::Connection, @backend, @connect_timeout, @inactivity_timeout
        }
      end
    end
  end
end
