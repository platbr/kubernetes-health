require 'prometheus/client'

module Puma
  module Kubernetes
    class Parser
      def initialize(clustered = false)
        register_default_kubernetes
        register_clustered_kubernetes if clustered
      end

      def parse(stats, labels = {})
        stats.each do |key, value|
          value.each { |s| parse(s, labels.merge(index: s['index'])) } if key == 'worker_status'
          parse(value, labels) if key == 'last_status'
          update_metric(key, value, labels)
        end
      end

      private

      def register_clustered_kubernetes
        registry.gauge(:puma_booted_workers, 'Number of booted workers').set({}, 1)
        registry.gauge(:puma_old_workers, 'Number of old workers').set({}, 0)
      end

      def register_default_kubernetes
        registry.gauge(:puma_backlog, 'Number of established but unaccepted connections in the backlog', index: 0)
        registry.gauge(:puma_running, 'Number of running worker threads', index: 0)
        registry.gauge(:puma_pool_capacity, 'Number of allocatable worker threads', index: 0)
        registry.gauge(:puma_max_threads, 'Maximum number of worker threads', index: 0)
        registry.gauge(:puma_workers, 'Number of configured workers').set({}, 1)
        registry.gauge(:puma_usage, 'Result of (1 - puma_pool_capacity/puma_max_threads)', index: 0)
      end

      def registry
        Prometheus::Client.registry
      end

      def update_metric(key, value, labels)
        return if registry.get("puma_#{key}").nil?

        registry.get("puma_#{key}").set(labels, value)
      end
    end
  end
end
