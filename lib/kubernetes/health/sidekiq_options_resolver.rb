module Kubernetes
  module Health
    class SidekiqOptionsResolver
      def self.[](key)
        # Sidekiq >= 6.0.0
        return Sidekiq[key] if Sidekiq.respond_to?('[]')

        Sidekiq.options[key]
      end
    end
  end
end