require 'eventmachine'

$stdout.sync = true

Signal.trap("INT")  { puts "Gracefully exiting"; EventMachine.stop }
Signal.trap("TERM") { puts "Gracefully exiting"; EventMachine.stop }

EM.kqueue if EM.kqueue? #osx
EM.epoll  if EM.epoll? #linux

module EventMachine
  class MitmProxy
    def initialize options
      @listen = options.delete(:listen) || 9999
      @verbose = options.delete(:verbose) || false
      @ct = options.delete(:ct) || 2
      @it = options.delete(:it) || 2
    end

    def report msg
      puts "#{Time.now.strftime("%F %T.%L")} - #{msg}"
    end

    def start!
      EventMachine.run {
        report "Starting proxy balancer"
        EventMachine.start_server '127.0.0.1', @listen, Mitm::Connection, @ct, @it, @verbose
      }
    end
  end
end
