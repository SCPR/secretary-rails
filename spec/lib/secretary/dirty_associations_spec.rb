require 'spec_helper'

describe Secretary::DirtyAssociations do
  let(:other_story) {
    create :story,
      :headline         => "Cooler Story, Bro",
      :body             => "Some cooler text."
  }
end
