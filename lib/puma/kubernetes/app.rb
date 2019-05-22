require 'json'
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
        req = ::Rack::Request.new(_env)
        type = {}
        content = []
        case req.path_info
        when ::Kubernetes::Health::Config.route_readiness
          i_am_live = ::Kubernetes::Health::Config.live_if.arity == 0 ? ::Kubernetes::Health::Config.live_if.call : ::Kubernetes::Health::Config.live_if.call(req.params)
          http_code = i_am_live ? 200 : 503
        when ::Kubernetes::Health::Config.route_liveness
          i_am_ready = ::Kubernetes::Health::Config.ready_if.arity == 0 ? ::Kubernetes::Health::Config.ready_if.call : ::Kubernetes::Health::Config.ready_if.call(req.params)
          http_code = i_am_ready ? 200 : 503
        when ::Kubernetes::Health::Config.route_metrics
          http_code = 200
          @parser.parse JSON.parse(@launcher.stats)
          type = { 'Content-Type' => 'text/plain' }
          content = [Prometheus::Client::Formats::Text.marshal(Prometheus::Client.registry)]
        else
          http_code = 404
        end
        Rails.logger.info "Kubernetes Health: Rack on Migrate - Request: Path: #{req.path_info} / Params: #{req.params} /  HTTP Code: #{http_code}" rescue nil
        [http_code, type, content]
      end
    end
  end
end
