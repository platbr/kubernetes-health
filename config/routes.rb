Rails.application.routes.draw do
  get Kubernetes::Health::Config.route_liveness, to: 'kubernetes/health#liveness'
  get Kubernetes::Health::Config.route_readiness, to: 'kubernetes/health#readiness'
end