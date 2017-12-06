module Kubernetes
  class HealthController < ActiveController::Base
    def status
      if ActiveRecord::Base.connection.execute("SELECT 1").cmd_tuples == 1
        head 200
      else
        head 503
      end
    end
  end
end