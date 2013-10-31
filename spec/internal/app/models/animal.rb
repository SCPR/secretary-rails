class Animal < ActiveRecord::Base
  has_secretary

  belongs_to :person

  self.versioned_attributes = ["name", "color"]
end
