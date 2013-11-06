class Image < ActiveRecord::Base
  has_secretary on: ["title", "url"]

  belongs_to :story
  tracks_association :story
end
