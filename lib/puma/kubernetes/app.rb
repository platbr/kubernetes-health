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
          type = { 'Content-Type' => 'text/plain' }
          case req.path_info
          when ::Kubernetes::Health::Config.route_liveness
            i_am_live = ::Kubernetes::Health::Config.live_if.arity == 0 ? ::Kubernetes::Health::Config.live_if.call : ::Kubernetes::Health::Config.live_if.call(req.params)
            http_code = i_am_live ? 200 : 503
          when ::Kubernetes::Health::Config.route_readiness
            i_am_ready = ::Kubernetes::Health::Config.ready_if.arity == 0 ? ::Kubernetes::Health::Config.ready_if.call : ::Kubernetes::Health::Config.ready_if.call(req.params)
            http_code = i_am_ready ? 200 : 503
          when ::Kubernetes::Health::Config.route_metrics
            http_code = 200
            @parser.parse JSON.parse(@launcher.stats)
            content = [Prometheus::Client::Formats::Text.marshal(Prometheus::Client.registry)]
          else
            http_code = 404
          end
        rescue
          http_code = 500
          content = []
        end
        ::Kubernetes::Health::Config.request_log_callback.call(req, http_code)
        [http_code, type, content]
      end
    end
  end
end
