module LLT
  module Core
    # Module that holds the shared functionality of all
    # LLT Services.
    #
    # cf. specs for documentation
    module Serviceable
      def self.included(klass)
        klass.extend(ClassMethods)
      end

      DEFAULT_OPTIONS = {}

      # Initializes a new service instance and configures its services
      def initialize(options = {})
        configure(options)
        set_default_options(options)
        register
      end

      # Registers self in the service_class with force
      def register!
        guarded do
          write_to_register
        end
      end

      private

      def set_default_options(opts)
        # do not want to capture any service instance here
        relevant_opts = opts.reject { |k, _| used_services.include?(k) == :db }
        @default_options = DEFAULT_OPTIONS.merge(relevant_opts)
      end

      def parse_option(opt, options)
        # we cannot just do option || true, because some options might
        # be a totally legitimate false
        (option = options[opt]).nil? ? @default_options[opt] : option
      end

      # Sets instance variables for all used services.
      def configure(options)
        used_services.each do |service, def_instance|
          inst = options[service] || registered(service) || def_instance.call
          instance_variable_set("@#{service}", inst)
        end
      end

      def registered(service)
        guarded do
          service_class.fetch(service)
        end
      end

      def register
        guarded do
          write_to_register unless service_class.registered?(service_name)
        end
      end

      def used_services
        self.class.used_services
      end

      def guarded
        if service_class
          yield
        end
      end

      def write_to_register
        service_class.register(service_name => self)
      end

      # Class that is used to register a service.
      # Returns LLT::Service if it is defined.
      def service_class
        if defined?(LLT::Service)
          LLT::Service
        else
          nil
        end
      end

      # Name used to register service
      # Should be implemented by including class
      def service_name
        :undefined_service
      end
    end

    module ClassMethods
      def used_services
        @used_services ||= {}
      end

      def method_missing(meth, *args, &blk)
        if meth.match(/^uses_(.*)/)
          key = $1.to_sym
          used_services[key] = blk
          attr_accessor key
        else
          super
        end
      end

      def respond_to_missing?(meth, include_private = false)
        meth.match(/^uses_(.*)/) || super
      end
    end
  end
end
