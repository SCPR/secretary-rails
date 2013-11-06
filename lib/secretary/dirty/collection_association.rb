module Secretary
  module Dirty
    module CollectionAssociation
      extend ActiveSupport::Concern

      module ClassMethods
        private

        def add_dirty_collection_association_methods(name)
          module_eval <<-EOE, __FILE__, __LINE__ + 1
            def #{name}_were
              @#{name}_were ||= collection_association_was("#{name}")
            end

            def #{name}_changed?
              collection_association_changed?("#{name}")
            end


            private

            def preload_#{name}(object)
              #{name}_were
            end

            def check_for_#{name}_changes
              check_for_collection_association_changes("#{name}")
            end

            def clear_dirty_#{name}
              @#{name}_were = nil
            end
          EOE
        end
      end


      private

      # This has to be run in a before_save callback,
      # because we can't rely on the after_add, etc. callbacks
      # to fill in our custom changes. For example, setting
      # `self.animals_attributes=` doesn't run these callbacks.
      def check_for_collection_association_changes(name)
        persisted   = self.send("#{name}_were")
        current     = self.send(name).to_a.reject(&:marked_for_destruction?)

        persisted_attributes  = persisted.map(&:versioned_attributes)
        current_attributes    = current.map(&:versioned_attributes)

        if persisted_attributes != current_attributes
          ensure_custom_changes_for_collection_association(name, persisted)
          self.custom_changes[name][1] = current_attributes
        end
      end

      def collection_association_was(name)
        self.persisted? ? self.class.find(self.id).send(name).to_a : []
      end

      def collection_association_changed?(name)
        check_for_collection_association_changes(name)
        self.custom_changes[name].present?
      end

      def ensure_custom_changes_for_collection_association(name, persisted=nil)
        self.custom_changes[name] ||= [
          (persisted || self.send("#{name}_were")).map(&:versioned_attributes),
          Array.new
        ]
      end
    end
  end
end
