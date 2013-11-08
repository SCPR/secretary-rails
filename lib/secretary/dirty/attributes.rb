module Secretary
  module Dirty
    # This module overrides the methods in ActiveModel::Dirty to inject our
    # custom changes.
    module Attributes
      extend ActiveSupport::Concern
    end
  end
end
