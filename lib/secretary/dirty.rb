module Secretary
  module Dirty
    extend ActiveSupport::Autoload

    autoload :CollectionAssociation
    autoload :SingularAssociation
  end
end
