class User < ActiveRecord::Base
  has_many :activities, class_name: "Secretary::Version"
end
