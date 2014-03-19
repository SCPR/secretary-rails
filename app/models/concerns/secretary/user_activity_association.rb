module Secretary
  module UserActivityAssociation
    extend ActiveSupport::Concern

    included do
      has_many :activities,
        :class_name     => "Secretary::Version",
        :foreign_key    => "user_id"
    end
  end
end
