namespace :kubernetes_health do
  task :before_migrate do
    Thread.new {
      require 'rack'
      @counter=0
      Rack::Handler.default.run ->(env) {
        req = Rack::Request.new(env)
        valid = req.path_info == "#{Kubernetes::Health::Config.route_readiness}"
        if valid
          @counter=@counter+1
          http_codes = Kubernetes::Health::Config.rack_on_migrate_rotate_http_codes
          http_code = http_codes[(@counter % http_codes.size)]
        else
          http_code = 404
        end
        Rails.logger.info "Kubernetes Health: Rack on Migrate - Path: #{req.path_info} / Params: #{req.params} / Count: #{@counter} / HTTP Code: #{http_code}"
        [http_code, {}, []]
      }
    }
  end
end
Rake::Task['db:migrate'].enhance(['kubernetes_health:before_migrate'])
