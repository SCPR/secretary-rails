require 'spec_helper'

describe Secretary::UserActivityAssociation do
  it "adds an activities association to the user class" do
    user = build :user
    user.activities.to_a.should eq []
  end
end
