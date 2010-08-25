module DoubleTrouble
  module Protection
    extend ActiveSupport::Concern

    included do
      class_inheritable_accessor :allow_double_trouble_protection
      cattr_accessor             :double_trouble_nonce_store
      cattr_accessor             :double_trouble_nonce_param
      helper_method              :protect_against_double_trouble?, :double_trouble_nonce_param, :double_trouble_form_nonce

      self.allow_double_trouble_protection = true
    end

    module ClassMethods
      def protect_from_double_trouble(resource_name, options = {})
        self.double_trouble_nonce_param ||= :form_nonce
        self.double_trouble_nonce_store ||= CachedNonce

        around_filter(options.slice(:only, :except)) do |controller, action_block|
          if controller.send(:protect_against_double_trouble?)
            nonce = controller.params[double_trouble_nonce_param]

            double_trouble_nonce_store.valid?(nonce) || raise(InvalidNonce)

            action_block.call

            controller.instance_variable_get("@#{resource_name}").tap do |resource|
              resource.present? && !resource.new_record? && double_trouble_nonce_store.store!(nonce)
            end
          else
            action_block.call
          end
        end
      end
    end

    module InstanceMethods
      protected
      def double_trouble_form_nonce
        ActiveSupport::SecureRandom.base64(32)
      end

      def protect_against_double_trouble?
        allow_double_trouble_protection && double_trouble_nonce_store && double_trouble_nonce_param
      end
    end
  end
end
