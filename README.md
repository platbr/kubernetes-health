# Kubernetes::Health

This gem allows kubernetes monitoring your app while it is running migrates and after it started.

# Features
- add routes `/_readiness` and `/_liveness` on rails stack by default.
- allow custom checks for `/_readiness` and `/_liveness` on rails stack.
- add routes `/_readiness` and `/_liveness` while `rake db:migrate` runs. (optional). 

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'kubernetes-health', '~> 2.0'
```

## Enabling monitoring while `rake db:migrate` runs

Your Dockerfile's entry script needs to run migrates before start your web app.

Add `KUBERNETES_HEALTH_ENABLE_RACK_ON_MIGRATE=true` environment variable.

or add in your `application.rb`.

```
    # default: false
    Kubernetes::Health::Config.enable_rack_on_migrate = true
```

If you need customize http rotating codes:

```
    # default: [200, 503]
    Kubernetes::Health::Config.rack_on_migrate_rotate_http_codes = [200, 503]
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

### How `rake db:migrate` monitoring works
It will run a RACK server for `/_readiness` and `/_liveness` routes while a `rake db:migrate` runs and it will return `200` and `503` HTTP CODES alternately avoiding to reach `failureThreshold` or `successThreshold`.

The `failureThreshold` and `successThreshold` values must to greater than `2` forcing kubernetes to wait.

## Customizing checks

It only works for routes in rails stack, they are not executed while `rake db:migrate` runs.

Ex. Check if PostgreSQL is reachable. `params` is optional.

```
Kubernetes::Health::Config.ready_if = lambda { |params|
    ActiveRecord::Base.connection.execute("SELECT 1").cmd_tuples != 1
}
```

```
Kubernetes::Health::Config.live_if = lambda { |params|
    ActiveRecord::Base.connection.execute("SELECT 1").cmd_tuples != 1
}
```

## Customizing routes
```
Kubernetes::Health::Config.route_liveness = '/liveness'
Kubernetes::Health::Config.route_readiness = '/readiness
```
