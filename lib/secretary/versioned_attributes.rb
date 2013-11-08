module Secretary
  module VersionedAttributes
    extend ActiveSupport::Concern

    included do
      class << self
        # Set the attributes which Secretary should keep track of.
        #
        # Example:
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
        attr_writer :versioned_attributes

        def versioned_attributes
          @versioned_attributes ||=
            self.column_names -
            Secretary.config.ignored_attributes -
            unversioned_attributes
        end

        def unversioned_attributes=(array)
          self.versioned_attributes -= array
        end

        private

        def unversioned_attributes
          @unversioned_attributes ||= []
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
            previous = previous.versioned_attributes
            current  = current.versioned_attributes
          end
        end

        modified_changes[key] = [previous, current]
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
  end
end
