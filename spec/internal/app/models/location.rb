class Location < ActiveRecord::Base
  has_secretary

  has_many :people
  tracks_association :people
end
