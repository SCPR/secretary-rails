module Secretary
  class Engine < ::Rails::Engine
    config.after_initialize do
      Secretary.config.user_class.constantize.instance_eval do
        include Secretary::UserActivityAssociation
      end
    end
  end
end
