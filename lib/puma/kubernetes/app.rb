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
        @parser = Parser.new(clustered: clustered)
      end

      def call(_env)
        begin
          req = ::Rack::Request.new(_env)
          type = {}
          content = ''
          type = ::Kubernetes::Health::Config.response_format == 'json' ? { 'Content-Type' => 'application/json' } : { 'Content-Type' => 'text/plain' }
          extended_puma_stats = generate_extended_puma_stats
          case req.path_info
          when ::Kubernetes::Health::Config.route_liveness
            i_am_live = ::Kubernetes::Health::Config.live_if.arity.zero? ? ::Kubernetes::Health::Config.live_if.call : ::Kubernetes::Health::Config.live_if.call(req.params)
            http_code = i_am_live ? 200 : 503
          when ::Kubernetes::Health::Config.route_readiness
            i_am_ready = ::Kubernetes::Health::Config.ready_if.arity.zero? ? ::Kubernetes::Health::Config.ready_if.call : ::Kubernetes::Health::Config.ready_if.call(req.params)
            http_code = puma_already_started?(extended_puma_stats) && i_am_ready ? 200 : 503
          when ::Kubernetes::Health::Config.route_metrics
            http_code = 200
            if ::Kubernetes::Health::Config.response_format == 'json'
              content = puma_status_json(extended_puma_stats)
            else
              prometheus_parse_status!(extended_puma_stats)
              content = Prometheus::Client::Formats::Text.marshal(Prometheus::Client.registry)
            end
          else
            http_code = 404
          end
        rescue StandardError => e
          puts e.message
          puts e.backtrace.join("\n")
          http_code = 500
          content = ''
        end
        ::Kubernetes::Health::Config.request_log_callback.call(req, http_code, content)
        [http_code, type, [content]]
      end

      private

      def prometheus_parse_status!(extended_puma_stats)
        @parser.parse(extended_puma_stats)
      end

      def generate_extended_puma_stats
        begin
          puma_stats = @launcher.stats
        rescue NoMethodError
          puma_stats = {}
        end
        # On puma <= 4 puma_stats is a String
        puma_stats = JSON.parse(puma_stats, symbolize_names: true) if puma_stats.is_a?(String)
        # Including usage stats.
        puma_stats = merge_worker_status(puma_stats) unless puma_stats[:worker_status]&.empty?
        puma_stats[:usage] = (1 - puma_stats[:pool_capacity].to_f / puma_stats[:max_threads]).round(2) unless puma_stats[:pool_capacity]&.empty?
        puma_stats
      end

      def merge_worker_status(stats)
        merded_stats = stats[:worker_status].map { |ws| ws[:last_status] }.inject({}) { |sum, hash| sum.merge(hash) { |_key, val1, val2| val1+val2 } }
        stats.each_key do |k|
          merded_stats[k] = stats[k]
        end

        merded_stats
      end

      def puma_status_json(extended_puma_stats)
        include_puma_key_prefix(extended_puma_stats).to_json
      end

      def include_puma_key_prefix(stats)
        result = {}
        stats.each do |k, v|
          result["puma_#{k}"] = v
        end
        result
      end

      def puma_already_started?(extended_puma_stats)
        return false if extended_puma_stats.empty?

        # Single Mode
        return extended_puma_stats[:running].positive? unless extended_puma_stats[:running]&.empty?

        # Cluster Mode
        extended_puma_stats[:booted_workers].positive?
      end
    end
  end
end
