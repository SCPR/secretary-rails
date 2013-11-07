module Secretary
  class Version < ActiveRecord::Base
    serialize :object_changes

    belongs_to :versioned, :polymorphic => true
    belongs_to :user, :class_name => Secretary.config.user_class

    validates_presence_of :versioned

    before_create :increment_version_number


    class << self
      # Builds a new version for the passed-in object
      # Passed-in object is a dirty object.
      # Version will be saved when the object is saved.
      #
      # If you must generate a version manually, this
      # method should be used instead of `Version.create`.
      # I didn't want to override the public ActiveRecord
      # API.
      def generate(object)
        object.versions.create({
          :user_id          => object.logged_user_id,
          :description      => generate_description(object),
          :object_changes   => object.versioned_changes
        })
      end


      private

      def generate_description(object)
        if was_created?(object)
          "Created #{object.class.name.titleize} ##{object.id}"

        elsif was_updated?(object)
          attributes = object.versioned_changes.keys
          "Changed #{attributes.to_sentence}"

        else
          "Generated Version"
        end
      end


      def was_created?(object)
        object.persisted? && object.id_changed?
      end

      def was_updated?(object)
        object.persisted? && !object.id_changed?
      end
    end


    # The attribute diffs for this version
    def attribute_diffs
      @attribute_diffs ||= begin
        changes           = self.object_changes.dup
        attribute_diffs   = {}

        # Compare each of object_b's attributes to object_a's attributes
        # And if there is a difference, add it to the Diff
        changes.each do |attribute, values|
          # values is [previous_value, new_value]
          diff = Diffy::Diff.new(values[0].to_s, values[1].to_s)
          attribute_diffs[attribute] = diff
        end

        attribute_diffs
      end
    end

    # A simple title for this version.
    # Example: "Article #125 v6"
    def title
      "#{self.versioned.class.name.titleize} " \
      "##{self.versioned.id} v#{self.version_number}"
    end


    private

    def increment_version_number
      latest_version = self.versioned.versions.order("version_number").last
      self.version_number = latest_version.try(:version_number).to_i + 1
    end
  end
end
