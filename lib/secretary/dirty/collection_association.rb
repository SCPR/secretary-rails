module Secretary
  module Dirty
    module CollectionAssociation
      extend ActiveSupport::Concern

      module ClassMethods
        private

        def add_dirty_collection_association_methods(name)
          module_eval <<-EOE, __FILE__, __LINE__ + 1

            def #{name}_changed?
              attribute_changed?("#{name}")
            end

            def #{name}_change
              attribute_change("#{name}")
            end

            def #{name}_were
              attribute_was("#{name}")
            end

            def #{name}_will_change!
              attribute_will_change!("#{name}")
            end

            private

            def prepare_#{name}_to_change(object)
              #{name}_will_change!
            end
          EOE
        end
      end


      private

      def assign_to_or_mark_for_destruction(record, *args)
        klass = record.class
        name = self.class.reflections.find { |r| r[1].klass == klass }[0]
        super(record, *args)
        binding.pry
        send("#{name}_will_change!")
        binding.pry
      end
    end
  end
end
