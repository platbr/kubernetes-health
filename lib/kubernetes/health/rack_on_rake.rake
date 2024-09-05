require 'rack'
require 'kubernetes/health/rack_on_rake'

namespace :kubernetes_health do
  task :rack_on_rake do
    Thread.new do
      Rack::Handler::WEBrick.run Kubernetes::Health::RackOnRake.new, Port: Kubernetes::Health::Config.metrics_port
    end
  end
end
