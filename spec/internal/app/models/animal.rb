class Animal < ActiveRecord::Base
  has_secretary on: ["name", "color"]

  belongs_to :person
end
