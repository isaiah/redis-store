require 'digest/sha1'
require 'rack/utils'
require 'rack/cache/key'
require 'rack/cache/metastore'

module Rack
  module Cache
    class MetaStore
      class RedisBase < self
        extend Rack::Utils

        # The Redis::Store object used to communicate with the Redis daemon.
        attr_reader :cache

        def self.resolve(uri)
          uri = uri.to_s if uri.kind_of?(URI::Generic)
          new ::Redis::Store::Factory.resolve(uri)
        end
      end

      class Redis < RedisBase
        # The Redis instance used to communicated with the Redis daemon.
        attr_reader :cache

        def initialize(server, options = {})
          @cache = ::Redis::Store::Factory.create(server)
        end

        def read(key)
          cache.get(hexdigest(key)) || []
        end

        def write(key, entries)
          cache.set(hexdigest(key), entries)
        end

        def purge(key)
          cache.del(hexdigest(key))
          nil
        end
      end

      REDIS = Redis
    end
  end
end
