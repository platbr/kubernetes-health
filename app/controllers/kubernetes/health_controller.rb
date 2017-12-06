module Kubernetes
  class HealthController < ::ActionController::Base
    def status
      if Kubernetes::Health::Config.sick_if.call
        head 503
      else
        head 200
      end
    end
  end
end