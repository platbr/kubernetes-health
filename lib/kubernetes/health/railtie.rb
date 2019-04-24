module Kubernetes
  module Health
    class Railtie < Rails::Railtie
      rake_tasks do
        load 'kubernetes/health/rack_on_migrate.rake' if Kubernetes::Health::Config.enable_rack_on_migrate
        load 'kubernetes/health/lock_on_migrate.rake' if Kubernetes::Health::Config.enable_lock_on_migrate
      end
    end
  end
end
