module Kubernetes
  module Health
    class Config
      @@sick_if = lambda { false }
      @@route = '/_health'

      def self.route
        @@route
      end

      def self.route=(value)
        @@route
      end

      def self.sick_if
        @@sick_if
      end

      def self.sick_if=(value)
        @@sick_if = value
      end
    end
  end
end