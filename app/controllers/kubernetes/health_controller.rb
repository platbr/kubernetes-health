module Kubernetes
  class HealthController < ::ActionController::Base
    def status
      i_am_sick = Kubernetes::Health::Config.sick_if.arity == 0 ? Kubernetes::Health::Config.sick_if.call : Kubernetes::Health::Config.sick_if.call(params)
      return head 503 if i_am_sick
      head 200
    end
  end
end