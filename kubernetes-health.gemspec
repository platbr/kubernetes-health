# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'kubernetes/health/version'

Gem::Specification.new do |spec|
  spec.name          = "kubernetes-health"
  spec.version       = Kubernetes::Health::VERSION
  spec.authors       = ["Wagner Caixeta"]
  spec.email         = ["wagner@baladapp.com.br"]

  spec.summary       = %q{A simple gem to add /_health to your Rails APP.}
  spec.description   = %q{A simple gem to add /_health to your Rails APP for using with Kubernetes}
  spec.homepage      = "https://github.com/platbr/kubernetes-health"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.14"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end
