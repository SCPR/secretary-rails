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

          # If the environment is loaded, the following line will be
          # evaluated for any `tracks_association` calls.
          # `versioned_attributes` calls `self.column_names`,
          # which requires the table to exist.
          #
          # So the problem is that if our database or table doesn't exist,
          # we can't load the environment, and the environment needs to be
          # loaded in order to load in the schema.
          #
          # So, we rescue! And warn.
          begin
            self.versioned_attributes << name.to_s

            if reflection.macro == :belongs_to
              self.versioned_attributes << reflection.foreign_key
            end

          rescue => e
            warn  "[secretary-rails] Caught an error while loading " \
                  "#{self.name}. #{e}"
          end

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

      reflection = self.class.reflections.find do |name, reflection|
        reflection.klass >= klass
      end

      reflection[0] if reflection
    end
  end
end
