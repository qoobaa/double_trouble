module DoubleTrouble
  module Protection
    def self.included(base)
      base.class_eval do
        class_inheritable_accessor :allow_double_trouble_protection
        class_inheritable_accessor :double_trouble_resource_name
        cattr_accessor             :double_trouble_nonce_storage
        cattr_accessor             :double_trouble_nonce_param
        helper_method              :protect_against_double_trouble?, :double_trouble_nonce_param, :double_trouble_form_nonce

        self.allow_double_trouble_protection = true
        extend(ClassMethods)
      end
    end

    module ClassMethods
      def protect_from_double_trouble(resource_name, options = {})
        self.double_trouble_resource_name   = resource_name
        self.double_trouble_nonce_param   ||= :form_nonce
        self.double_trouble_nonce_storage ||= CachedNonce

        around_filter :double_trouble_protection, options.slice(:only, :except)
      end
    end

    protected

    def double_trouble_protection
      if protect_against_double_trouble?
        nonce    = params[double_trouble_nonce_param]
        resource = instance_variable_get("@#{double_trouble_resource_name}")
        storage  = double_trouble_nonce_storage

        storage.valid?(nonce) || raise(InvalidNonce)
        yield
        resource.present? && !resource.new_record? && storage.store!(nonce)
      else
        yield
      end
    end

    def double_trouble_form_nonce
      ActiveSupport::SecureRandom.base64(32)
    end

    def protect_against_double_trouble?
      allow_double_trouble_protection &&
        double_trouble_resource_name &&
        double_trouble_nonce_storage &&
        double_trouble_nonce_param
    end
  end
end
