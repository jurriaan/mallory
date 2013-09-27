require 'spec_helper'
require 'mallory/logger'

describe EventMachine::Mallory::Logger do
  let(:logger) {EventMachine::Mallory::Logger.instance}
  let(:debug_logger) do 
    debug_logger = EventMachine::Mallory::Logger.instance
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
    logger1 = EventMachine::Mallory::Logger.instance
    logger2 = EventMachine::Mallory::Logger.instance
    expect(logger1).to be(logger2)
  end

  it "logs without debug" do
    out = capture_stdout do
      logger.info "Some text"
      logger.debug "Some other text"
    end
    expect(out.string).to match(/.*Some text$/)
  end

  it "logs with debug" do
    out = capture_stdout do
      debug_logger.info "Some text"
      debug_logger.debug "Some other text"
    end
    expect(out.string).to match(/.*Some text.*Some other text$/m)
  end

end
