require "sidekiq/concurrency_safety/version"

module Sidekiq
  module ConcurrencySafety
    class AlreadyRunningError < StandardError; end

    def perform(*args)
      @args = args

      redis_key = key_generator

      redis_pool.with do |r|
        raise AlreadyRunningError unless r.set(redis_key, 1, ex: final_ttl, nx: true)

        begin
          super
        ensure
          r.del(redis_key)
        end
      end
    end

    private

    attr_reader :args

    def key_generator
      ["job_running", self.class.name, final_key].join(":")
    end

    def final_key
      concurrency_key_exists? ? concurrency_key : args.map(&:to_s)
    end

    def final_ttl
      methods.include?(:ttl) ? ttl : 25_000
    end

    def concurrency_key_exists?
      methods.include?(:concurrency_key)
    end

    def redis_pool
      Sidekiq.redis_pool
    end
  end
end
