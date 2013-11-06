class Location < ActiveRecord::Base
  has_secretary

  has_many :people
  has_and_belongs_to_many :cars

  tracks_association :people
end
