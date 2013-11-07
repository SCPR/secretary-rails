module Secretary
  module Dirty
    # This module overrides the methods in ActiveModel::Dirty to inject our
    # custom changes.
    module Attributes
      def changed?
        super || custom_changes.present?
      end

      def changes
        self.custom_changes.reverse_merge super
      end

      def custom_changes
        @custom_changes ||= ActiveSupport::HashWithIndifferentAccess.new
      end


      private

      if ActiveRecord::VERSION::STRING >= "4.1.0"
        def changes_applied
          super
          clear_custom_changes
        end
      end

      def clear_custom_changes
        @custom_changes = {}
      end
    end
  end
end
