module CellForce
  class << self
    def configuration
      @configuration ||= Configuration.new
    end

    def configure
      yield configuration
    end
  end

  class Configuration
    class Error < ::StandardError; end
    [:username, :password, :api_key].each do |accessor|
      define_method(:"#{accessor}=") do |arg|
        raise Error, "#{accessor} must be a String" unless arg.nil? || arg.is_a?(String)
        raise Error, "#{accessor} cannot be blank" if arg.nil? || arg.empty?
        @credentials = @headers = nil
        instance_variable_set("@#{accessor}", arg)
      end

      define_method(accessor) do
        instance_variable_get("@#{accessor}").tap do |result|
          raise Error, "#{accessor} has not been set.  Set it with `CellForce.configuration.#{accessor} = ...`" if result.nil?
        end
      end
    end

    def credentials
      @credentials ||= { username: username, password: password }
    end

    def headers
      @headers ||= { "apikey" => api_key }
    end
  end
end
