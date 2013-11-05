class Person < ActiveRecord::Base
  has_secretary

  belongs_to :location

  has_many :animals
  accepts_nested_attributes_for :animals, allow_destroy: true

  has_many :hobbies

  tracks_association :animals, :hobbies

  self.unversioned_attributes = ["name", "ethnicity"]
end
