module Kubernetes
  module Health
    class Engine < ::Rails::Engine
      engine_name 'kubernetes_health'
      isolate_namespace Kubernetes::Health
    end
  end
end