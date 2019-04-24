# Kubernetes::Health

This gem allows kubernetes monitoring your app while it is running migrates and after it started.

# Features
- add routes `/_readiness` and `/_liveness` on rails stack by default.
- allow custom checks for `/_readiness` and `/_liveness` on rails stack.
- add routes `/_readiness` and `/_liveness` while `rake db:migrate` runs. (optional)
- add support to avoid parallel running of `rake db:migrate` while keep kubernetes waiting. (optional)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'kubernetes-health', '~> 2.1'
```

## Enabling monitoring while `rake db:migrate` runs

Your Dockerfile's entry script needs to run migrates before start your web app.

Add `KUBERNETES_HEALTH_ENABLE_RACK_ON_MIGRATE=true` environment variable.

or add in your `application.rb`.

```
# default: false
Kubernetes::Health::Config.enable_rack_on_migrate = true
```

In Kubernetes you need to configure your deployment `readinessProbe` like this:

```
    livenessProbe:
        httpGet:
        path: /_liveness
        port: 80
        initialDelaySeconds: 10
        timeoutSeconds: 5
    readinessProbe:
        httpGet:
        path: /_readiness
        port: 80
        initialDelaySeconds: 10
        timeoutSeconds: 5
```

### How `rake db:migrate` monitoring works
It will run a RACK server for `/_readiness` and `/_liveness` routes while `rake db:migrate` is running.

## Avoid `rake db:migrate` parallel running.

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
