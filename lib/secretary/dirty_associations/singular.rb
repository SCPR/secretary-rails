module Secretary
  module DirtyAssociations
    module Singular
      extend ActiveSupport::Concern

      module ClassMethods
        private

        def define_singular_association_writer(name)
          module_eval <<-EOE, __FILE__, __LINE__ + 1
            def #{name}=(record)
              #{name}_will_change!
              super
            end
          EOE
        end
      end


      private

      def assign_nested_attributes_for_one_to_one_association(association_name, *args)
        send("#{association_name}_will_change!")
        super(association_name, *args)
      end
    end
  end
end
