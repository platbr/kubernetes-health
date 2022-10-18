require 'puma/kubernetes/dsl'

Puma::Plugin.create do
  # rubocop:disable Kubernetes/MethodLength, Kubernetes/AbcSize
  def start(launcher)
    str = launcher.options[:kubernetes_url] || 'tcp://0.0.0.0:9393'

    require 'puma/kubernetes/app'

    app = Puma::Kubernetes::App.new launcher
    uri = URI.parse str

    puma_options = { min_threads: 0, max_threads: 1 }
    kubernetes = Puma::Server.new app, launcher.log_writer, launcher.events, puma_options

    case uri.scheme
    when 'tcp'
      launcher.log_writer.log "* Starting kubernetes-healh server on #{str}"
      kubernetes.add_tcp_listener uri.host, uri.port
    else
      launcher.log_writer.error "Invalid control URI: #{str}"
    end

    launcher.events.register(:state) do |state|
      if %i[halt restart stop].include?(state)
        kubernetes.stop(true) unless kubernetes.shutting_down?
      end
    end

    kubernetes.run
  end
  # rubocop:enable Kubernetes/MethodLength, Kubernetes/AbcSize
end
