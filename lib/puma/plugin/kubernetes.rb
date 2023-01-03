require 'puma/kubernetes/dsl'

Puma::Plugin.create do
  # rubocop:disable Kubernetes/MethodLength, Kubernetes/AbcSize
  def start(launcher)
    str = launcher.options[:kubernetes_url] || 'tcp://0.0.0.0:9393'

    require 'puma/kubernetes/app'

    app = Puma::Kubernetes::App.new launcher
    uri = URI.parse str
    log_writer = launcher.respond_to?(:log_writer) ? launcher.log_writer : launcher.events
    puma_options = { min_threads: 0, max_threads: 1 }
    puma_options[:log_writer] = log_writer unless log_writer.nil?
    puma_server = Puma::Server.new app, launcher.events, puma_options

    case uri.scheme
    when 'tcp'
      log_writer.log "* Starting kubernetes-healh server on #{str}"
      puma_server.add_tcp_listener uri.host, uri.port
    else
      log_writer.error "Invalid control URI: #{str}"
    end

    launcher.events.register(:state) do |state|
      if %i[halt restart stop].include?(state)
        puma_server.stop(true) unless puma_server.shutting_down?
      end
    end

    puma_server.run
  end
  # rubocop:enable Kubernetes/MethodLength, Kubernetes/AbcSize
end
