module Secretary
  module DirtyAssociations
    extend ActiveSupport::Concern
    extend ActiveSupport::Autoload

    autoload :Collection
    autoload :Singular

    COLLECTION_SUFFIX   = "_were"
    SINGULAR_SUFFIX     = "_was"


    module ClassMethods
      private

      def define_dirty_association_methods(name, reflection)
        suffix = reflection.collection? ? COLLECTION_SUFFIX : SINGULAR_SUFFIX

        module_eval <<-EOE, __FILE__, __LINE__ + 1
          def #{name}_changed?
            attribute_changed?("#{name}")
          end

          def #{name}#{suffix}
            attribute_was("#{name}")
          end

          def #{name}_change
            attribute_change("#{name}")
          end

          def #{name}_will_change!
            return if attribute_changed?("#{name}")

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

            changed_attributes["#{name}"] = previous
          end

          def reset_#{name}!
            reset_attribute!("#{name}")
          end
        EOE
      end

      def add_callback_methods(callback_name, reflection, new_methods)
        reflection.options[callback_name] ||= Array.new
        reflection.options[callback_name] += new_methods
      end

      # Necessary for Rails < 4.1
      def redefine_callback(callback_name, name, reflection)
        send("#{callback_name}_for_#{name}=",
          Array(reflection.options[callback_name])
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

      if self.class.reflect_on_association(name).collection?
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
  end
end
