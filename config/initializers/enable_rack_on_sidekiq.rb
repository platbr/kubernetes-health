require 'kubernetes/health/rack_on_sidekiq'

if Kubernetes::Health::Config.enable_rack_on_sidekiq && Kubernetes::Health::SidekiqOptionsResolver[:concurrency].positive?
  Thread.new do
    Rack::Handler.default.run Kubernetes::Health::RackOnSidekiq.new
  end
end