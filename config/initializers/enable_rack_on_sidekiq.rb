require 'kubernetes/health/rack_on_sidekiq'

if Kubernetes::Health::Config.enable_rack_on_sidekiq && Sidekiq.options[:concurrency].positive?
  Thread.new do
    Rack::Handler.default.run Kubernetes::Health::RackOnSidekiq.new
  end
end