module Secretary
  module Dirty
    module SingularAssociation
      extend ActiveSupport::Concern

      module ClassMethods
        private

        def add_dirty_singular_association_methods(name)
          module_eval <<-EOE, __FILE__, __LINE__ + 1
            def #{name}_was
              if defined?(@#{name}_was)
                @#{name}_was
              else
                @#{name}_was = singular_association_was("#{name}")
              end
            end

            def #{name}_changed?
              singular_association_changed?("#{name}")
            end

            def #{name}=(value)
              preload_#{name}
              obj = super
              check_for_#{name}_changes
              obj
            end

            private

            def preload_#{name}(object=nil)
              #{name}_was
            end

            def check_for_#{name}_changes
              check_for_singular_association_changes("#{name}")
            end

            def clear_dirty_#{name}
              remove_instance_variable(:@#{name}_was)
            end
          EOE
        end
      end


      private

      # This has to be run in a before_save callback,
      # because we can't rely on the after_add, etc. callbacks
      # to fill in our custom changes. For example, setting
      # `self.animals_attributes=` doesn't run these callbacks.
      def check_for_singular_association_changes(name)
        persisted   = self.send("#{name}_was")
        current     = self.send(name)

        persisted_attributes = persisted ? persisted.versioned_attributes : {}

        current_attributes = if current && !current.marked_for_destruction?
          current.versioned_attributes
        else
          {}
        end

        if persisted_attributes != current_attributes
          self.custom_changes[name] = [
            persisted_attributes,
            current_attributes
          ]
        end
      end

      def singular_association_was(name)
        self.persisted? ? self.class.find(self.id).send(name) : nil
      end

      def singular_association_changed?(name)
        check_for_singular_association_changes(name)
        self.custom_changes[name].present?
      end
    end
  end
end
