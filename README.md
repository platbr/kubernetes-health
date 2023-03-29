# Kubernetes::Health
This gem open a HTTP port for monitoring your rails app while it is running Migrates, Sidekiq and Puma.

# Features
- Puma and Sidekiq metrics for autoscaling.
- Prometheus and JSON metrics (tested using https://github.com/zalando-incubator/kube-metrics-adapter and JSON format).
- add routes `/_readiness`, `/_liveness` on Rails Stack.
- add routes `/_readiness`, `/_liveness` and `/_metrics` as a puma plugin at another port to avoid problems when your app get busy. (code copied from `puma-metrics` gem).
- add routes `/_readiness` and `/_liveness` while `rake db:migrate` runs. (optional)
- add routes `/_readiness` and `/_liveness` while `sidekiq` runs. (optional)
- add support to avoid parallel running of `rake db:migrate` while keep kubernetes waiting (PostgreSQL required).
- allow custom checks for `/_readiness` and `/_liveness`.
 
## Installation

Add this line to your application's Gemfile:

```ruby
gem 'kubernetes-health', '~> 3.6'
```

## Enabling puma plugin

add in `config/puma.rb`
```
plugin 'kubernetes'
kubernetes_url 'tcp://0.0.0.0:9393'
```

In Kubernetes you need to configure your deployment `readinessProbe` and `livenessProbe` like this:

```
        livenessProbe:
          httpGet:
            path: /_liveness
            port: 9393
          initialDelaySeconds: 30
          timeoutSeconds: 5
          failureThreshold: 3
          successThreshold: 1
        readinessProbe:
          httpGet:
            path: /_readiness
            port: 9393
          initialDelaySeconds: 30
          timeoutSeconds: 5
          failureThreshold: 3
          successThreshold: 1
```

Setting `failureThreshold` is import to avoid problems when app finish migrates and is starting the web process.

## Enabling monitoring while `rake db:migrate` runs

Your Dockerfile's entry script needs to run migrates before start your web app.

Add `KUBERNETES_HEALTH_ENABLE_RACK_ON_MIGRATE=true` environment variable.

or add in your `application.rb`.

```
# default: false
Kubernetes::Health::Config.enable_rack_on_migrate = true
```
The defined port at `config/puma.rb` will be used.

## Enabling monitoring for `sidekiq`

Add `KUBERNETES_HEALTH_ENABLE_RACK_ON_SIDEKIQ=true` environment variable.

or add in your `application.rb`.

```
# default: false
Kubernetes::Health::Config.enable_rack_on_sidekiq = true
```
The defined port at `config/puma.rb` will be used.

### How `rake db:migrate` and `sidekiq` monitoring works
It will run a RACK server for `/_readiness`, `/_liveness` and `/_metrics`.

## Avoiding migrations running in parallel and making kubernetes happy.
Rails already avoid migrations running in parallel, but it raise exceptions. This gem will just wait for other migrations without exit.
If you enable `rack_on_migrate` together with this, kubernetes will just wait, avoiding erros.


Add `KUBERNETES_HEALTH_ENABLE_LOCK_ON_MIGRATE=true` environment variable.

or add in your `application.rb`.

```
# default: false
Kubernetes::Health::Config.enable_lock_on_migrate = true
```

### Customizing locking
By default it is working for PostgreSQL, but you can customize it using a lambda:
```
Kubernetes::Health::Config.lock_or_wait = lambda {
    ActiveRecord::Base.connection.execute 'select pg_advisory_lock(123456789123456789);'
}

Kubernetes::Health::Config.unlock = lambda {
    ActiveRecord::Base.connection.execute 'select pg_advisory_unlock(123456789123456789);'
}
```

## Customizing checks

It only works for routes in rails stack, they are not executed while `rake db:migrate` runs.

I prefer do nothing else on `liveness` to avoid unnecessary `CrashLoopBackOff` status. `params` is optional (request params).

```
Kubernetes::Health::Config.live_if = lambda { |params|
  true
}

```
Ex. Check if PostgreSQL is reachable on `readiness` indicating that credentials are setup right and keeps cache to avoid doing it a lot. `params` is optional (request params).
```
Kubernetes::Health::Config.ready_if = lambda { |params|
  return $kubernetes_health_test_db_connection if $kubernetes_health_test_db_connection
  $kubernetes_health_test_db_connection = ActiveRecord::Base.connection.execute("SELECT 1").cmd_tuples == 1
}
```

## Customizing routes
```
Kubernetes::Health::Config.route_liveness = '/liveness'
Kubernetes::Health::Config.route_readiness = '/readiness'
Kubernetes::Health::Config.route_metrics = '/metrics'
```
or using env
```
KUBERNETES_HEALTH_LIVENESS_ROUTE='/liveness'
KUBERNETES_HEALTH_READINESS_ROUTE='/readiness'
KUBERNETES_HEALTH_RESPONSE_FORMAT='/metrics'
```

## Response format
If you are using `https://github.com/zalando-incubator/kube-metrics-adapter` you will want to use `json` format.

Default is `prometheus`.
```
Kubernetes::Health::Config.response_format = 'json'
```
or using env
```
KUBERNETES_HEALTH_RESPONSE_FORMAT=json
```

## Customizing requests logs

```
Kubernetes::Health::Config.request_log_callback = lambda { |req, http_code, content|
  Rails.logger.debug "Kubernetes Health: Rack on Migrate - Request: Path: #{req.path_info} / Params: #{req.params} /  HTTP Code: #{http_code}\n#{content}"  rescue nil
}
```
