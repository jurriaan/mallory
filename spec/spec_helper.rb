require 'rspec'
require 'thin'
require 'em-http-request'
require 'responder'

RSpec.configure do |config|
  config.order = 'random'

#  config.before(:all) do
#    Thread.new { EM.run  }
#    trap(:INT) { EM.stop }
#    trap(:TERM){ EM.stop }
#    web = Thin::Server.new(Responder, '127.0.0.1', 6701)
#    web.silent = true
#    web.start
#    p web.running?
#    sleep 5
#  end

#  config.after(:all) do
#    EM.stop
#  end

end
