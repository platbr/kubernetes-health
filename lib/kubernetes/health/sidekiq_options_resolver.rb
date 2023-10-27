module Kubernetes
  module Health
    class SidekiqOptionsResolver
      def self.[](key)
        return Sidekiq[key] if Sidekiq.respond_to?('[]')
        return Sidekiq.options[key] if Sidekiq.respond_to?('options') # Sidekiq ~> 6.0
        return Sidekiq::Config.new[key] if defined?(Sidekiq::Config) # Sidekiq ~> 7.0

        raise 'Sidekiq version not supported'
      end
    end
  end
end