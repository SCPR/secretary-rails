module Secretary
end

require 'secretary/engine'
require 'secretary/config'
require 'secretary/errors'
require 'diffy'

module Secretary
  extend ActiveSupport::Autoload

  class << self
    attr_writer :config
    def config
      @config || Secretary::Config.configure
    end

    def versioned_models
      @versioned_models ||= []
    end
  end

  autoload :HasSecretary
  autoload :VersionedAttributes
  autoload :TracksAssociation
end

ActiveSupport.on_load(:active_record) do
  include Secretary::HasSecretary
  include Secretary::TracksAssociation
  include Secretary::VersionedAttributes
end
