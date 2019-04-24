# Kubernetes::Health

A gem that adds `/_readiness` and `/_liveness` and allows Kubernetes monitor your rails using HTTP while migrates are running.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'kubernetes-health', '~> 2.0'
```

And then execute:

$ bundle

## Enable migrates monitoring.

It will run a Rack server for `/_readiness` route and will return `200` and `503` HTTP CODES alternately while your migrates are running.

If readinessProbe\'s failureThreshold=3 and successThreshold=3 it will never be reach until migrate finish.

Your Dockerfile's entry script needs to run migrates before start your web app.

Add `KUBERNETES_HEALTH_ENABLE_RACK_ON_MIGRATE=true` environment variable.

or

```
    Kubernetes::Health::Config.enable_rack_on_migrate = true # default: false
```

On your app.

If you need custom HTTP rotating codes:

```
    Kubernetes::Health::Config.rack_on_migrate_rotate_http_codes = [200, 503] # default: [202, 503]
```

In Kubernetes you need to configure your deployment `readinessProbe` like this:
```
    readinessProbe:
        httpGet:
        path: /_readiness
        port: 80
        initialDelaySeconds: 10
        timeoutSeconds: 5
        failureThreshold: 3
        successThreshold: 3
```

## Custom check

Set Kubernetes::Health::Config.ready_if if you want to check other things.

Ex. Check if PostgreSQL is working. `params` is optional.
```
Kubernetes::Health::Config.ready_if = lambda { |params|
    ActiveRecord::Base.connection.execute("SELECT 1").cmd_tuples != 1
}
```

Set Kubernetes::Health::Config.live_if if you want to check other things.

Ex. Check if PostgreSQL is working. `params` is optional.
```
Kubernetes::Health::Config.ready_if = lambda { |params|
    ActiveRecord::Base.connection.execute("SELECT 1").cmd_tuples != 1
}
```


## Custom routes
```
Kubernetes::Health::Config.route_liveness = '/liveness'
Kubernetes::Health::Config.route_readiness = '/readiness
```
