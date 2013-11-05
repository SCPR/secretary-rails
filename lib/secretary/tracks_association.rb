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

            def preload_#{name}_were(object)
              #{name}_were
            end

            def check_for_#{name}_changes
              check_for_association_changes("#{name}")
            end

            def clear_dirty_#{name}
              @#{name}_were = nil
            end
          EOE

          before_save :"check_for_#{name}_changes"
          after_commit :"clear_dirty_#{name}"

          add_callback_methods("before_add_for_#{name}", [
            :"preload_#{name}_were"
          ])

          add_callback_methods("before_remove_for_#{name}", [
            :"preload_#{name}_were"
          ])

          add_callback_methods("after_add_for_#{name}", [])
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

      # This has to be run in a before_save callback,
      # because we can't rely on the after_add, etc. callbacks
      # to fill in our custom changes. For example, setting
      # `self.animals_attributes=` doesn't run these callbacks.
      def check_for_association_changes(name)
        persisted   = self.send("#{name}_were")
        current     = self.send(name).to_a.reject(&:marked_for_destruction?)

        persisted_attributes  = persisted.map(&:versioned_attributes)
        current_attributes    = current.map(&:versioned_attributes)

        if persisted_attributes != current_attributes
          ensure_custom_changes_for_association(name, persisted)
          self.custom_changes[name][1] = current_attributes
        end
      end

      def association_was(name)
        self.persisted? ? self.class.find(self.id).send(name).to_a : []
      end

      def association_changed?(name)
        check_for_association_changes(name)
        self.custom_changes[name].present?
      end

      def ensure_custom_changes_for_association(name, persisted=nil)
        self.custom_changes[name] ||= [
          (persisted || self.send("#{name}_were")).map(&:versioned_attributes),
          Array.new
        ]
      end
    end
  end
end
