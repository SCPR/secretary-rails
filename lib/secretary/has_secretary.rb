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

        after_save :generate_version, :if => lambda { self.changed? }

        include InstanceMethodsOnActivation
      end
    end


    module InstanceMethodsOnActivation
      # Generate a version for this object.
      def generate_version
        Version.generate(self)
      end
    end
  end
end
