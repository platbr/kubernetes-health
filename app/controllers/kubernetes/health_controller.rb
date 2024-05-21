module Kubernetes
  class HealthController < ::ActionController::Base
    def liveness
      i_am_live = Kubernetes::Health::Config.live_if.arity == 0 ? Kubernetes::Health::Config.live_if.call : Kubernetes::Health::Config.live_if.call(params)
      return head 200 if i_am_live
      head 503
    end

    def readiness
      puts "arity: " + Kubernetes::Health::Config.ready_if.arity
      puts "call: " + Kubernetes::Health::Config.ready_if.call
      i_am_ready = Kubernetes::Health::Config.ready_if.arity == 0 ? Kubernetes::Health::Config.ready_if.call : Kubernetes::Health::Config.ready_if.call(params)
      return head 200 if i_am_ready
      head 503
    end
  end
end