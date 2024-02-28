module Kubernetes
  module Health
    class RackOnRake
      def call(env)
        req = ::Rack::Request.new(env)
        case req.path_info
        when Kubernetes::Health::Config.route_readiness
          http_code = 503
        when Kubernetes::Health::Config.route_liveness
          http_code = 200
        else
          http_code = 404
        end
        ::Kubernetes::Health::Config.request_log_callback.call(req, http_code, '')
        [http_code, {}, []]
      end
    end
  end
end