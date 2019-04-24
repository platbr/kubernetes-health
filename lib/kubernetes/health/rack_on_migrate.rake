require 'rack'
require "kubernetes/health/rack_on_migrate"
namespace :kubernetes_health do
  task :rack_on_migrate do
    Thread.new {
      Rack::Handler.default.run Kubernetes::Health::RackOnMigrate.new
    }
  end
end
Rake::Task['db:migrate'].enhance(['kubernetes_health:rack_on_migrate'])
