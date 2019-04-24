module Kubernetes
  module Health
    class Config
      @@live_if = lambda { true }
      @@ready_if = lambda { true }
      @@enable_rack_on_migrate = ActiveRecord::Type::Boolean.new.cast(ENV['KUBERNETES_HEALTH_ENABLE_RACK_ON_MIGRATE']) || false
      @@rack_on_migrate_rotate_http_codes = [503, 200]
      @@route_liveness = '/_liveness'
      @@route_readiness = '/_readiness'

      def self.enable_rack_on_migrate
        @@enable_rack_on_migrate
      end

      def self.enable_rack_on_migrate=(value)
        @@enable_rack_on_migrate = value
      end

      def self.rack_on_migrate_rotate_http_codes
        @@rack_on_migrate_rotate_http_codes
      end

      def self.rack_on_migrate_rotate_http_codes=(value)
        @@rack_on_migrate_rotate_http_codes = value
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
    end
  end
end