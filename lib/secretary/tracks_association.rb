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
      #     :as           => :content,
      #     :class_name   => "ContentByline",
      #     :dependent    => :destroy
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

        associations.each do |name|
          reflection = self.reflect_on_association(name)

          if !reflection
            raise NoAssociationError, name, self.name
          end

          self.versioned_attributes << name.to_s

          if reflection.collection?
            include Dirty::CollectionAssociation
            add_dirty_collection_association_methods(name)

            add_callback_methods("before_add_for_#{name}", [
              :"preload_#{name}"
            ])

            add_callback_methods("before_remove_for_#{name}", [
              :"preload_#{name}"
            ])

          else
            include Dirty::SingularAssociation
            add_dirty_singular_association_methods(name)
          end

          before_save :"check_for_#{name}_changes"
          after_commit :"clear_dirty_#{name}"
        end
      end

      private

      def add_callback_methods(method_name, new_methods)
        original  = send(method_name)
        methods   = original + new_methods
        send("#{method_name}=", methods)
      end
    end
  end
end
