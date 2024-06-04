require 'kubernetes/health/rack_on_sidekiq'

if Kubernetes::Health::Config.enable_rack_on_sidekiq && Kubernetes::Health::SidekiqOptionsResolver[:concurrency].positive?
  Thread.new do
    Rack::Handler::WEBrick.run Kubernetes::Health::RackOnSidekiq.new, Port: Kubernetes::Health::Config.metrics_port
  end
end
