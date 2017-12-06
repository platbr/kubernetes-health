Rails.application.routes.draw do
  get '/_health', to: 'kubernetes/health#status'
end