module Puma
  class DSL
    def kubernetes_url(url)
      @options[:kubernetes_url] = url
    end
  end
end
