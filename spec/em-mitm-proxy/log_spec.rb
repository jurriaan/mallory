require 'spec_helper'
require 'em-mitm-proxy/logger'

describe Mitm::Logger do
  let(:logger) {Mitm::Logger.instance}
  let(:debug_logger) do 
    debug_logger = Mitm::Logger.instance
    debug_logger.verbose = true
    debug_logger
  end

  def capture_stdout
    out = StringIO.new
    $stdout = out
    yield
    return out
  ensure
    $stdout = STDOUT
  end

  it "creates logger singleton" do
    logger1 = Mitm::Logger.instance
    logger2 = Mitm::Logger.instance
    expect(logger1).to be(logger2)
  end

  it "logs without debug" do
    out = capture_stdout do
      logger.report "Some text"
      logger.debug "Some other text"
    end
    expect(out.string).to match(/.*Some text$/)
  end

  it "logs with debug" do
    out = capture_stdout do
      debug_logger.report "Some text"
      debug_logger.debug "Some other text"
    end
    expect(out.string).to match(/.*Some text.*Some other text$/m)
  end

end
