module Secretary
  module HasSecretary
    extend ActiveSupport::Concern

    module ClassMethods
      # (Boolean) Check if a class is versioned
      # Story.has_secretary? # => true or false
      def has_secretary?
        !!@_has_secretary
      end

      # Declare that this class shoudl be versioned.
      # 
      # Options:
      # * `on` : Array of Strings which specifies which attributes should be
      #   versioned.
      # * `except` : Array of Strings which specifies which attributes should
      #   NOT be versioned.
      def has_secretary(options={})
        @_has_secretary = true
        Secretary.versioned_models.push self.name

        self.versioned_attributes   = options[:on]     if options[:on]
        self.unversioned_attributes = options[:except] if options[:except]

        has_many :versions,
          :class_name   => "Secretary::Version",
          :as           => :versioned,
          :dependent    => :destroy

        attr_accessor :logged_user_id

        after_save    :generate_version, if: -> { self.changed? }
        after_commit  :clear_custom_changes

        send :include, InstanceMethodsOnActivation
      end
    end


    module InstanceMethodsOnActivation
      # Generate a version for this object.
      def generate_version
        Version.generate(self)
      end

      # Use Rails built-in Dirty attributions to get
      # the easy ones. By the time we're generating
      # this version, this hash could already
      # exist with some custom changes.
      def changes
        self.custom_changes.reverse_merge super
      end

      # Use Rails' `changed?`, plus check our own custom changes
      # to see if an object has been modified.
      def changed?
        super || custom_changes.present?
      end

      # Similar to ActiveModel::Dirty#changes, but lets us
      # pass in some custom changes (such as associations)
      # which wouldn't be picked up by the built-in method.
      #
      # This method should only be used for adding custom changes
      # to the changes hash. For storing and comparing and whatnot,
      # use #changes as usual.
      #
      # This method basically exists just to get around the behavior
      # of #changes (since it sends the attribute message to the
      # object, which we don't always want, for associations for
      # example).
      def custom_changes
        @custom_changes ||= HashWithIndifferentAccess.new
      end


      private

      def clear_custom_changes
        self.custom_changes.clear
      end
    end
  end
end
