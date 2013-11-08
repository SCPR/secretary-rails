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

        include DirtyAssociations

        associations.each do |name|
          reflection = self.reflect_on_association(name)

          if !reflection
            raise NoAssociationError, name, self.name
          end

          self.versioned_attributes << name.to_s

          define_dirty_association_methods(name, reflection)

          if reflection.collection?
            include DirtyAssociations::Collection
            add_collection_callbacks(name, reflection)
          else
            include DirtyAssociations::Singular
            define_singular_association_writer(name)
          end
        end
      end
    end


    private

    def association_name(association_object)
      klass = association_object.class
      name = self.class.reflections.find { |r| r[1].klass == klass }[0]
    end
  end
end
