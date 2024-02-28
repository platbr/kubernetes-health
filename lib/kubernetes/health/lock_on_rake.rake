namespace :kubernetes_health do
  task :lock_on_rake do
    Rails.logger.info "Kubernetes Health: Lock on Migrate - Locking or waiting started."
    Kubernetes::Health::Config.lock_or_wait.call
    Rails.logger.info "Kubernetes Health: Lock on Migrate - Locking or waiting finished."
    at_exit {
      Rails.logger.info "Kubernetes Health: Lock on Migrate - Unlocking started."
      Kubernetes::Health::Config.unlock.call
      Rails.logger.info "Kubernetes Health: Lock on Migrate - Unlocking finished."
    }
  end
end