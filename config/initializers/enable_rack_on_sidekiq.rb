require 'kubernetes/health/rack_on_sidekiq'
begin
  require 'rackup'
rescue LoadError
  # ignore
end

if Kubernetes::Health::Config.enable_rack_on_sidekiq && Kubernetes::Health::SidekiqOptionsResolver[:concurrency].positive?
  Thread.new do
    server = defined?(Rackup::Handler::WEBrick) ? Rackup::Handler::WEBrick : Rack::Handler::WEBrick
    server.run Kubernetes::Health::RackOnSidekiq.new, Port: Kubernetes::Health::Config.metrics_port
  end
end
