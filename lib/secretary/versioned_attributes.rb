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
    def versioned_changes
      self.changes.select { |k,_| versioned_attribute?(k) }.to_hash
    end

    def versioned_attributes
      self.as_json(root: false).select { |k,_| versioned_attribute?(k) }.to_hash
    end

    def versioned_attribute?(key)
      self.class.versioned_attributes.include?(key.to_s)
    end
  end
end
