require 'kubernetes/health/config'
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
          content = ''
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
              content = include_puma_key_prefix(include_usage(merge_worker_status_if_needed(@launcher.stats))).to_json
            else
              @parser.parse include_usage(merge_worker_status_if_needed(@launcher.stats))
              content = Prometheus::Client::Formats::Text.marshal(Prometheus::Client.registry)
            end
          else
            http_code = 404
          end
        rescue => e
          puts e.message
          puts e.backtrace.join("\n")
          http_code = 500
          content = ''
        end
        ::Kubernetes::Health::Config.request_log_callback.call(req, http_code, content)
        [http_code, type, [content]]
      end

      def merge_worker_status_if_needed(stats)
        return stats unless stats[:worker_status]

        merded_stats = stats[:worker_status].map { |ws| ws[:last_status] }.inject({}) { |sum, hash| sum.merge(hash) { |_key, val1, val2| val1+val2 } }
        merded_stats[:puma_started_at] = stats[:puma_started_at]
        merded_stats[:worker_status] = stats[:worker_status]
        merded_stats
      end

      def include_usage(stats)
        if stats.is_a?(String)
          # puma <= 4.
          stats = JSON.parse(stats)
        else
          # Puma >=5 uses symbol.
          stats = JSON.parse(stats.to_json)
        end
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
