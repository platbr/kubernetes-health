Rails.application.routes.draw do
  get Kubernetes::Health::Config.route, to: 'kubernetes/health#status'
end