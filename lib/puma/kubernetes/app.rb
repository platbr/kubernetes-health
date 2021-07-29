require "kubernetes/health/config"
require 'prometheus/client/formats/text'
require 'puma/kubernetes/parser'
require 'rack'

module Puma
  module Kubernetes
    class App
      def initialize(launcher)
        @launcher = launcher
        clustered = (@launcher.options[:workers] || 0) > 0
        @parser = Parser.new clustered
      end

      def call(_env)
        begin
          req = ::Rack::Request.new(_env)
          type = {}
          content = []
          type = ::Kubernetes::Health::Config.response_format == 'json' ? { 'Content-Type' => 'application/json' } : { 'Content-Type' => 'text/plain' }
          case req.path_info
          when ::Kubernetes::Health::Config.route_liveness
            i_am_live = ::Kubernetes::Health::Config.live_if.arity == 0 ? ::Kubernetes::Health::Config.live_if.call : ::Kubernetes::Health::Config.live_if.call(req.params)
            http_code = i_am_live ? 200 : 503
          when ::Kubernetes::Health::Config.route_readiness
            i_am_ready = ::Kubernetes::Health::Config.ready_if.arity == 0 ? ::Kubernetes::Health::Config.ready_if.call : ::Kubernetes::Health::Config.ready_if.call(req.params)
            http_code = i_am_ready ? 200 : 503
          when ::Kubernetes::Health::Config.route_metrics
            http_code = 200
            if ::Kubernetes::Health::Config.response_format == 'json'
              content = include_puma_key_prefix(include_usage(JSON.parse(@launcher.stats))).to_json
            else
              @parser.parse include_usage(JSON.parse(@launcher.stats))
              content = Prometheus::Client::Formats::Text.marshal(Prometheus::Client.registry)
            end
          else
            http_code = 404
          end
        rescue
          http_code = 500
          content = []
        end
        ::Kubernetes::Health::Config.request_log_callback.call(req, http_code, content)
        [http_code, type, [content]]
      end

      def include_usage(stats)
        stats['usage'] = (1 - stats['pool_capacity'].to_f / stats['max_threads']).round(2)
        stats
      end
      def include_puma_key_prefix(stats)
        result = {}
        stats.each do |k,v|
          result["puma_#{k}"] = v
        end
        result
      end
    end
  end
end
