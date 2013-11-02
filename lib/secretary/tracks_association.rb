module Secretary
  module TracksAssociation
    extend ActiveSupport::Concern

    module ClassMethods
      # Track the associations passed-in
      # This will make sure that when you change the association,
      # the saved record will get a new version, with association
      # diffs and everything.
      #
      # Example:
      #
      #   has_secretary
      #
      #   has_many :bylines,
      #     :as               => :content,
      #     :class_name       => "ContentByline",
      #     :dependent        => :destroy
      #
      #   tracks_association :bylines
      #
      # Forcing the changes into the custom_changes allows us
      # to keep track of dirty associations, so that checking stuff
      # like `changed?` will work.
      # 
      # If you want to control when an association should be left out of the
      # version, define an instance method named `should_reject_#{name}?`.
      # This method takes a hash of the model's attributes (so you can pass
      # in, for example, form params). This also lets you easily share this
      # method with `accepts_nested_attributes_for`.
      #
      # Example:
      #
      #   class Person < ActiveRecord::Base
      #     has_secretary
      #     has_many :animals
      #     tracks_association :animals
      #
      #     accepts_nested_attributes_for :animals,
      #       :reject_if => :should_reject_animals?
      #
      #     private
      #
      #     def should_reject_animals?(attributes)
      #       attributes['name'].blank?
      #     end
      #   end
      def tracks_association(*associations)
        if !self.has_secretary?
          raise NotVersionedError, self.name
        end

        self.versioned_attributes += associations.map(&:to_s)

        include InstanceMethodsOnActivation

        associations.each do |name|
          module_eval <<-EOE, __FILE__, __LINE__ + 1
            def #{name}_were
              @#{name}_were ||= association_was("#{name}")
            end

            def #{name}_changed?
              association_changed?("#{name}")
            end


            private

            def ensure_#{name}_changed
              ensure_association_changed("#{name}")
            end

            def add_to_changes_for_#{name}(object)
              add_to_changes_for_association("#{name}", object)
            end

            def preload_#{name}(object)
              #{name}_were
            end

            def ensure_custom_changes_for_#{name}(object)
              ensure_custom_changes_for_association("#{name}")
            end

            def clear_dirty_#{name}
              @#{name}_were = nil
            end
          EOE

          before_save :"ensure_#{name}_changed"
          after_commit :"clear_dirty_#{name}"

          add_callback_methods("before_add_for_#{name}", [
            :"preload_#{name}",
            :"ensure_custom_changes_for_#{name}"
          ])

          add_callback_methods("before_remove_for_#{name}", [
            :"preload_#{name}",
            :"ensure_custom_changes_for_#{name}"
          ])

          add_callback_methods("after_add_for_#{name}", [
            :"add_to_changes_for_#{name}"
          ])

          add_callback_methods("after_remove_for_#{name}", [])
        end
      end

      private

      def add_callback_methods(method_name, new_methods)
        original  = send(method_name)
        methods   = original + new_methods
        send("#{method_name}=", methods)
      end
    end


    module InstanceMethodsOnActivation
      private

      def ensure_association_changed(name)
        return if self.custom_changes[name].blank?

        # If the two sides of the changes are the same, then we should
        # just remove this key from the custom_changes hash, otherwise
        # `#changes` will think that changes have been made.
        #
        # This might happen if we are adding and removing stuff without
        # saving, then when we go to save, it turns out that nothing
        # actually changed. Or something like that.
        if self.custom_changes[name][0] == self.custom_changes[name][1]
          self.custom_changes.delete(name)
        end
      end

      def association_was(name)
        self.persisted? ? self.class.find(self.id).send(name).to_a : []
      end

      def association_changed?(name)
        ensure_association_changed(name)
        self.custom_changes[name].present?
      end

      # We have to used versioned_attributes here because it's likely
      # the object will have already been saved by Rails internals.
      def add_to_changes_for_association(name, object)
        return if object.marked_for_destruction?
        self.custom_changes[name][1].push object.versioned_attributes
      end

      def ensure_custom_changes_for_association(name)
        self.custom_changes[name] ||= [
          self.send("#{name}_were").map(&:versioned_attributes), []
        ]
      end
    end
  end
end
