require 'rack'
require "kubernetes/health/rack_on_migrate"

namespace :kubernetes_health do
  task :rack_on_migrate do
    Thread.new do
      Rack::Handler::WEBrick.run Kubernetes::Health::RackOnMigrate.new, { Port: Kubernetes::Health::Config.metrics_port }
    end
  end
end
Rake::Task['db:migrate'].enhance(['kubernetes_health:rack_on_migrate'])
