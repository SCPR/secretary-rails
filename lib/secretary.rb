module Secretary
end

require 'secretary/engine'
require 'secretary/config'
require 'secretary/errors'
require 'diffy'

module Secretary
  extend ActiveSupport::Autoload

  class << self
    # Pass a block to this method to define the configuration
    # If no block is passed, config will be defaults
    def configure
      config = Config.new
      yield config if block_given?
      self.config = config
    end

    attr_writer :config
    def config
      @config || configure
    end

    def versioned_models
      @versioned_models ||= []
    end
  end

  autoload :HasSecretary
  autoload :VersionedAttributes
  autoload :TracksAssociation
  autoload :DirtyAssociations
end

ActiveSupport.on_load(:active_record) do
  include Secretary::HasSecretary
  include Secretary::TracksAssociation
  include Secretary::VersionedAttributes
end
