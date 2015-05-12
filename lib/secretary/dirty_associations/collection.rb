module Secretary
  module DirtyAssociations
    module Collection
      extend ActiveSupport::Concern

      module ClassMethods
        CALLBACKS = [:before_add, :before_remove]

        private

        def add_collection_callbacks(name, reflection)
          CALLBACKS.each do |cb|
            add_callback_methods(cb, reflection,
              [:prepare_to_change_association])
          end

          if ActiveRecord::VERSION::STRING >= "4.1.0"
            CALLBACKS.each do |cb|
              ActiveRecord::Associations::Builder::HasMany
                .define_callback(self, cb, reflection.name, reflection.options)
            end
          else
            CALLBACKS.each do |cb|
              redefine_callback(cb, name, reflection)
            end
          end
        end
      end


      private


      # If the record wasn't changed, we need to reset the changed_attributes.
      # If there were previous changes, then reset the changes to the last
      # ones. Otherwise, just delete that empty key/value from the hash.
      def reset_changes_if_unchanged(record, name, previous)
        if record.versioned_changes.empty?
          name = name.to_s

          if previous
            __compat_set_attribute_was(name, previous)
          else
            __compat_clear_attribute_changes(name)
          end
        end
      end

      # This is just a proxy to association_will_change!
      # the before/after_add/remove callbacks pass an object,
      # but we don't need it, so this method accepts and throws
      # away that argument.
      def prepare_to_change_association(object)
        name = association_name(object)
        send("#{name}_will_change!")
      end
    end
  end
end
