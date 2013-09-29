require 'rspec'
require 'webrick'
require 'em-http-request'
require 'responder'
require 'logger'

RSpec.configure do |config|
  config.order = 'random'

  config.before(:suite) do
    trap(:INT) { EM.stop }
    trap(:TERM){ EM.stop }
    Thread.new do
      Rack::Handler::WEBrick.run(
        Responder.new,
        :Port => 6701,
        :AccessLog => [],
        :Logger => WEBrick::Log::new("/dev/null", 7))
    end
    sleep 3
  end

end
