module Secretary
  module DirtyAssociations
    extend ActiveSupport::Concern
    extend ActiveSupport::Autoload

    autoload :Collection
    autoload :Singular

    COLLECTION_SUFFIX   = "_were"
    SINGULAR_SUFFIX     = "_was"


    module ClassMethods
      # Backport of rails/rails#5383f22bb83adbd0e2e3f182f68196f1fb1433fa
      # For 4.2.0 support.
      if ActiveRecord::VERSION::STRING < "4.2.1"
        def persistable_attribute_names
          @persistable_attribute_names ||= connection
            .schema_cache.columns_hash(table_name).keys
        end

        def reset_column_information
          super
          @persistable_attribute_names = nil
        end
      end


      private

      def define_dirty_association_methods(name, reflection)
        suffix = reflection.collection? ? COLLECTION_SUFFIX : SINGULAR_SUFFIX

        module_eval <<-EOE, __FILE__, __LINE__ + 1
          def #{name}_changed?
            !!attribute_changed?("#{name}")
          end

          def #{name}#{suffix}
            attribute_was("#{name}")
          end

          def #{name}_change
            attribute_change("#{name}")
          end


          private

          def #{name}_will_change!
            return if #{name}_changed?

            # If this is a persisted object, fetch the object from the
            # database and get its associated objects. Otherwise, just
            # use self. We can't use `reload` here because it is a
            # destructive method and will lose the associations.
            record   = self.persisted? ? self.class.find(id) : self
            previous = record.#{name}

            # Since this might be called on a collection or singular
            # association, we need to force it into an array if possible.
            if self.class.reflect_on_association(:#{name}).collection?
              previous = previous.to_a
            end

            __compat_set_attribute_was("#{name}", previous)
          end

          # Rails < 4.2
          def reset_#{name}!
            reset_attribute!("#{name}")
          end

          # Rails 4.2+
          def restore_#{name}!
            restore_attribute!("#{name}")
          end
        EOE
      end

      def add_callback_methods(cb_name, reflection, new_methods)
        # The callbacks may not be an Array, so we'll force them into one.
        reflection.options[cb_name] = Array(reflection.options[cb_name])
        reflection.options[cb_name] += new_methods
      end

      # Necessary for Rails < 4.1
      # We need to force the callbacks into an array.
      def redefine_callback(cb_name, name, reflection)
        send("#{cb_name}_for_#{name}=",
          Array(reflection.options[cb_name])
        )
      end
    end


    private

    # For association_attributes=
    # Should we conditionally include this method? I would like to,
    # but if we're checking if this model accepts nested attributes
    # for the association, then accepts_nested_attributes_for would
    # have to be declared *before* tracks_association, which is too
    # strict for my tastes.
    def assign_to_or_mark_for_destruction(record, *args)
      name = association_name(record)

      if self.class.reflect_on_association(name).collection? &&
      versioned_attribute?(name)
        previous = changed_attributes[name]

        # Assume it will change. It may not. We'll handle that scenario
        # after the attributes have been assigned.
        send("#{name}_will_change!")
        super(record, *args)

        reset_changes_if_unchanged(record, name, previous)
      else
        super(record, *args)
      end
    end

    # Rails 4.2 adds "set_attribute_was" which must be used, so we'll
    # check for it.
    def __compat_set_attribute_was(name, previous)
      if respond_to?(:set_attribute_was, true)
        # Rails 4.2+
        set_attribute_was(name, previous)
      else
        # Rails < 4.2
        changed_attributes[name] = previous
      end
    end

    def __compat_clear_attribute_changes(name)
      if respond_to?(:clear_attribute_changes, true)
        # Rails 4.2+
        clear_attribute_changes([name])
      else
        # Rails < 4.2
        self.changed_attributes.delete(name)
      end
    end


    # Backport of rails/rails#5383f22bb83adbd0e2e3f182f68196f1fb1433fa
    # For 4.2.0 support.
    if ActiveRecord::VERSION::STRING < "4.2.1"
      def keys_for_partial_write
        super & self.class.persistable_attribute_names
      end
    end
  end
end
