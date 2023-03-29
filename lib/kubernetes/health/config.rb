module Kubernetes
  module Health
    class Config
      @@live_if = lambda { true }
      @@ready_if = lambda { true }
      @@enable_lock_on_migrate = [true, 'true'].include? ENV['KUBERNETES_HEALTH_ENABLE_LOCK_ON_MIGRATE']
      @@enable_rack_on_migrate = [true, 'true'].include? ENV['KUBERNETES_HEALTH_ENABLE_RACK_ON_MIGRATE']
      @@enable_rack_on_sidekiq = [true, 'true'].include? ENV['KUBERNETES_HEALTH_ENABLE_RACK_ON_SIDEKIQ']
      @@route_liveness = ENV['KUBERNETES_HEALTH_LIVENESS_ROUTE']  || '/_liveness'
      @@route_readiness = ENV['KUBERNETES_HEALTH_READINESS_ROUTE'] || '/_readiness'
      @@route_metrics = ENV['KUBERNETES_HEALTH_METRICS_ROUTE'] || '/_metrics'
      @@response_format = ENV['KUBERNETES_HEALTH_RESPONSE_FORMAT'] || 'prometheus'

      @@request_log_callback = lambda { |req, http_code, content|
        Rails.logger.debug "Kubernetes Health - Request: Path: #{req.path_info} / Params: #{req.params} /  HTTP Code: #{http_code}\n#{content}"  rescue nil
      }

      @@lock_or_wait = lambda { ActiveRecord::Base.connection.execute 'select pg_advisory_lock(123456789123456789);' }
      @@unlock = lambda { ActiveRecord::Base.connection.execute 'select pg_advisory_unlock(123456789123456789);' }

      def self.lock_or_wait
        @@lock_or_wait
      end

      def self.lock_or_wait=(value)
        @@lock_or_wait = value
      end

      def self.request_log_callback
        @@request_log_callback
      end

      def self.request_log_callback=(value)
        @@request_log_callback = value
      end

      def self.unlock
        @@unlock
      end

      def self.unlock=(value)
        @@unlock = value
      end

      def self.enable_lock_on_migrate
        @@enable_lock_on_migrate
      end

      def self.enable_lock_on_migrate=(value)
        @@enable_lock_on_migrate = value
      end

      def self.enable_rack_on_migrate
        @@enable_rack_on_migrate
      end

      def self.enable_rack_on_migrate=(value)
        @@enable_rack_on_migrate = value
      end

      def self.enable_rack_on_sidekiq
        @@enable_rack_on_sidekiq
      end

      def self.enable_rack_on_sidekiq=(value)
        @@enable_rack_on_sidekiq = value
      end

      def self.route_metrics
        @@route_metrics
      end

      def self.route_metrics=(value)
        @@route_metrics = value
      end

      def self.route_liveness
        @@route_liveness
      end

      def self.route_liveness=(value)
        @@route_liveness = value
      end

      def self.route_readiness
        @@route_readiness
      end

      def self.route_readiness=(value)
        @@route_readiness = value
      end

      def self.live_if
        @@live_if
      end

      def self.live_if=(value)
        @@live_if = value
      end

      def self.ready_if
        @@ready_if
      end

      def self.ready_if=(value)
        @@ready_if = value
      end

      def self.response_format
        @@response_format
      end

      def self.response_format=(value)
        @@response_format = value
      end
    end
  end
end