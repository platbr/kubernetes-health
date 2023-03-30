# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'kubernetes/health/version'

Gem::Specification.new do |spec|
  spec.name          = "kubernetes-health"
  spec.version       = Kubernetes::Health::VERSION
  spec.authors       = ["Wagner Caixeta"]
  spec.email         = ["wagner@baladapp.com.br"]

  spec.summary       = %q{This gem allows kubernetes monitoring your app while it is running migrates and after it started.}
  spec.description   = %q{
    This gem allows kubernetes monitoring your app while it is running migrates and after it started.
    Features:
    * add routes /_readiness and /_liveness on rails stack by default;
    * allow custom checks for /_readiness and /_liveness on rails stack;
    * add routes /_readiness and /_liveness while rake db:migrate runs.
  }
  spec.homepage      = "https://github.com/platbr/kubernetes-health"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_dependency "rack"
  spec.add_dependency "rails"
  spec.add_runtime_dependency 'prometheus-client', '>= 1.0', '< 5'
  spec.add_runtime_dependency 'puma', '>= 5.0'
end
