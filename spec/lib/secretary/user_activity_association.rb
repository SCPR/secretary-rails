require 'spec_helper'

describe Secretary::UserActivityAssociation do
  it "adds an activities association to the user class" do
    user = build :user
    expect(user.activities.to_a).to eq []
  end
end
