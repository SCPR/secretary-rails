module Secretary
  module Dirty
    extend ActiveSupport::Autoload

    autoload :Attributes
    autoload :CollectionAssociation
    autoload :SingularAssociation
  end
end
