require "mock_redis"
require "delegate"

RSpec.describe Sidekiq::ConcurrencySafety do
  let(:job_class) do
    Class.new(SimpleDelegator) do
      prepend Sidekiq::ConcurrencySafety
    end
  end

  subject { job_class.new(spy) }
  let(:job_key) { "job_key" }
  let(:key) { "job_running:#{job_class.name}" }
  let(:redis) { MockRedis.new }

  let(:connection_pool) { double :connection_pool }

  before do
    allow(connection_pool).to receive(:with).and_yield(redis)
    allow(subject).to receive(:redis_pool).and_return connection_pool
  end

  describe "#perform" do
    context "when the key has not been set" do
      let(:spy) { instance_spy "spy" }

      it "runs job" do
        subject.perform
        expect(spy).to have_received(:perform)
      end
    end

    context "after a failure" do
      let(:spy) { instance_spy "spy" }

      before do
        allow(spy).to receive(:perform).and_raise RuntimeError
        expect { subject.perform }.to raise_error(RuntimeError)
        allow(spy).to receive(:perform).and_return true
      end

      it "can be queued up again" do
        expect { subject.perform }.not_to raise_error
      end
    end

    context "when two instances try to run" do
      let(:spy) { instance_spy "spy", perform: true }

      before do
        allow(spy).to receive(:perform) { sleep 10 }
      end

      it "does not run job" do
        Thread.new { subject.perform }
        sleep 1
        expect { subject.perform }
          .to raise_error described_class::AlreadyRunningError
      end
    end

    context "when run with different arguments" do
      let(:spy) { instance_spy "spy" }

      before do
        allow(spy).to receive(:perform).with(:foo) { sleep 10 }
        allow(spy).to receive(:perform).with(:bar)
      end

      it "does not run job" do
        Thread.new { subject.perform(:foo) }
        sleep 1
        expect { subject.perform(:bar) }.not_to raise_error
      end
    end
  end
end
