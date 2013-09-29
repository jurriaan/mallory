require 'eventmachine'

$stdout.sync = true

Signal.trap("INT")  { puts "Gracefully exiting"; EventMachine.stop }
Signal.trap("TERM") { puts "Gracefully exiting"; EventMachine.stop }
# Signal.trap("USR1") { puts "Reloading log files" }

EM.kqueue if EM.kqueue? #osx
EM.epoll  if EM.epoll? #linux

module EventMachine
  module Mallory
    class Server
      def initialize config
        @logger = config.logger
        @listen = config.listen
        @request_builder = Mallory::RequestBuilder.new(config)
        response_builder = Mallory::ResponseBuilder.new(config)
        @proxy_builder = Mallory::ProxyBuilder.new(config, response_builder)
      end

      def start!
        EventMachine.run {
          @logger.info "Starting mallory"
          EventMachine.start_server '127.0.0.1', @listen, EventMachine::Mallory::Connection, @request_builder, @proxy_builder, @logger
        }
      end
    end
  end
end
