class Person < ActiveRecord::Base
  has_secretary except: ["name", "ethnicity"]

  belongs_to :location
  has_many :animals
  has_many :hobbies

  accepts_nested_attributes_for :animals, allow_destroy: true
  tracks_association :animals, :hobbies
end
