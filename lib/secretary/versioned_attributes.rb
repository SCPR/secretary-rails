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
        # Note: Setting `versioned_attributes` will cause
        # `unversioned_attributes` to be ignored.
        #
        # Note: These should be set before any `tracks_association`
        # macros are called.
        #
        # Each takes an array of column names *as strings*.
        attr_writer \
          :versioned_attributes,
          :unversioned_attributes

        def versioned_attributes
          @versioned_attributes ||=
            self.column_names -
            Secretary.config.ignored_attributes -
            unversioned_attributes
        end


        private

        def unversioned_attributes
          @unversioned_attributes ||= []
        end
      end
    end


    # The hash that gets serialized into the `object_changes` column.
    def version_hash
      self.changes.select { |k,_| versioned_attribute?(k) }.to_hash
    end

    def versioned_attribute?(key)
      self.class.versioned_attributes.include?(key.to_s)
    end
  end
end
