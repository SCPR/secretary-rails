class User < ActiveRecord::Base
  has_many :activities, class_name: "Secretary::Version"

  has_many :story_users
  has_many :stories, through: :story_users
end
