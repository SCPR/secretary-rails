module Secretary
  module DirtyAssociations
    module Singular
      extend ActiveSupport::Concern

      module ClassMethods
        private

        def define_singular_association_writer(name)
          module_eval <<-EOE, __FILE__, __LINE__ + 1
            def #{name}=(record)
              if record != self.#{name}
                #{name}_will_change!
              end

              super
            end
          EOE
        end
      end
    end
  end
end
