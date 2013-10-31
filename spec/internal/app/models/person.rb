class Person < ActiveRecord::Base
  has_secretary

  belongs_to :location

  has_many :animals
  has_many :hobbies
  tracks_association :animals, :hobbies

  self.unversioned_attributes = ["name", "ethnicity"]
end
