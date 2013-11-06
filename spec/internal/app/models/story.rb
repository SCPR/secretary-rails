class Story < ActiveRecord::Base
  has_secretary

  has_one :image
  accepts_nested_attributes_for :image, allow_destroy: true
  tracks_association :image
end
