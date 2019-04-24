module Kubernetes
  module Health
    class RackOnMigrate
      def call(env)
        req = Rack::Request.new(env)
        case req.path_info
        when Kubernetes::Health::Config.route_readiness
          http_code = 503
        when Kubernetes::Health::Config.route_liveness
          http_code = 200
        else
          http_code = 404
        end
        Rails.logger.info "Kubernetes Health: Rack on Migrate - Request: Path: #{req.path_info} / Params: #{req.params} /  HTTP Code: #{http_code}"
        [http_code, {}, []]
      end
    end
  end
end