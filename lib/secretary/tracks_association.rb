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

            attr_writer :#{name}_were

            def build_custom_changes_for_#{name}
              build_custom_changes_for_association("#{name}")
            end

            def mark_#{name}_as_changed(object)
              mark_association_as_changed("#{name}", object)
            end

            def preload_#{name}(object)
              #{name}_were
            end
          EOE

          before_save :"build_custom_changes_for_#{name}"
          after_commit :clear_custom_changes

          send("before_add_for_#{name}=", Array(:"preload_#{name}"))
          send("before_remove_for_#{name}=", Array(:"preload_#{name}"))
          send("after_add_for_#{name}=", Array(:"mark_#{name}_as_changed"))
          send("after_remove_for_#{name}=", Array(:"mark_#{name}_as_changed"))
        end
      end
    end


    module InstanceMethodsOnActivation
      private

      # Collection is the original collection
      def build_custom_changes_for_association(name)
        return if !self.changed?

        original = self.send("#{name}_were").map(&:version_hash)
        current  = self.send(name).reject(&:marked_for_destruction?)
          .map(&:version_hash)

        if original != current
          self.custom_changes[name] = [original, current]
        end
      end

      def association_was(name)
        persisted? ? self.class.find(self.id).send(name).to_a : []
      end

      def association_changed?(name)
        self.custom_changes[name].present?
      end

      def mark_association_as_changed(name, object)
        rejector = "should_reject_#{name}?"
        if object.respond_to?(rejector)
          return if send(rejector, object.attributes.stringify_keys)
        end

        self.custom_changes[name] = [
          send("#{name}_were").map(&:version_hash),
          send(name).map(&:version_hash)
        ]
      end

      def clear_custom_changes
        self.custom_changes.clear
      end
    end
  end
end
