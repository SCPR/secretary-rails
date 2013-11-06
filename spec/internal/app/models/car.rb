class Car < ActiveRecord::Base
  has_secretary
  has_and_belongs_to_many :locations
  accepts_nested_attributes_for :locations, allow_destroy: true
  tracks_association :locations
end
