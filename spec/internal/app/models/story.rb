class Story < ActiveRecord::Base
  has_secretary

  has_one :image
  accepts_nested_attributes_for :image, :allow_destroy => true
  tracks_association :image

  has_many :story_users
  has_many :users, :through => :story_users
  accepts_nested_attributes_for :users, :allow_destroy => true
  tracks_association :users

  # Github #14
  tracks_association :story_users
end
