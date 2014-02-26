module Secretary
  module VersionedAttributes
    extend ActiveSupport::Concern

    included do
      class << self
        # Set the attributes which Secretary should keep track of.
        #
        # Arguments
        #
        # * attributes - (Hash) The attributes that should be versioned.
        #
        # Example
        #
        #   class Article < ActiveRecord::Base
        #     self.versioned_attributes = [:id, :created_at]
        #   end
        #
        # Instead of setting `versioned_attributes` explicitly,
        # you can set `unversioned_attributes` to tell Secretary
        # which attributes to ignore.
        #
        # Each takes an array of column names *as strings*.
        #
        # Returns Hash
        def versioned_attributes=(attributes)
          verify_strings!(attributes)
          @versioned_attributes = attributes
        end

        def versioned_attributes
          @versioned_attributes ||=
            self.column_names -
            Secretary.config.ignored_attributes -
            unversioned_attributes
        end

        def unversioned_attributes=(attributes)
          verify_strings!(attributes)
          self.versioned_attributes -= attributes
        end

        private

        def unversioned_attributes
          @unversioned_attributes ||= []
        end

        def verify_strings!(array)
          if array.any? { |e| !e.is_a?(String) }
            raise ArgumentError,
              "Versioned attributes must be declared as strings."
          end
        end
      end
    end


    # The hash that gets serialized into the `object_changes` column.
    #
    # This takes the `changes` hash and processes the associations to be
    # human-readable objects.
    def versioned_changes
      modified_changes = {}
      raw_changes = self.changes.select {|k,_| versioned_attribute?(k)}.to_hash

      raw_changes.each do |key, (previous, current)|
        if reflection = self.class.reflect_on_association(key.to_sym)
          if reflection.collection?
            previous = previous.map(&:versioned_attributes)
            current  = current.map(&:versioned_attributes)
          else
            previous = previous ? previous.versioned_attributes : {}

            current  = if current && !current.marked_for_destruction?
              current.versioned_attributes
            else
              {}
            end
          end
        end

        # This really shouldn't need to be here,
        # but there is some confusion if we're destroying
        # an associated object in a save callback on the
        # parent object. We can't know that the callback
        # is going to destroy this object on save,
        # so we just have to add the association normally
        # and then filter it out here.
        if previous != current
          modified_changes[key] = [previous, current]
        end
      end

      modified_changes
    end

    # The object's versioned attributes as a hash.
    def versioned_attributes
      json = self.as_json(:root => false).select do |k,_|
        versioned_attribute?(k)
      end

      json.to_hash
    end

    # Check if the passed-in attribute is versioned.
    def versioned_attribute?(key)
      self.class.versioned_attributes.include?(key.to_s)
    end


    private

    # Memoized version changes.
    # This is just so when we're near the end of an object's journey to
    # persistence, we don't have to keep running the whole `versioned_changes`
    # method, which is rather expensive. When we reach that point, we can
    # be reasonably certain that no additional changes will occur, so it's
    # safe to memoize the method. However, while an object is being modified,
    # memoizing would be wrong, since that hash it constantly changing.
    def __versioned_changes
      @__versioned_changes ||= versioned_changes
    end

    def reset_versioned_changes
      @__versioned_changes = nil
    end
  end
end
