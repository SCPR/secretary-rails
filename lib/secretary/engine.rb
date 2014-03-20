module Secretary
  class Engine < ::Rails::Engine
    # This is necessary to support rails 3, which doesn't autoload
    # the concerns directory
    config.autoload_paths << File.expand_path(
      "../../../../app/models/concerns", __FILE__)

    config.after_initialize do
      Secretary.config.user_class.constantize.instance_eval do
        include Secretary::UserActivityAssociation
      end
    end
  end
end
